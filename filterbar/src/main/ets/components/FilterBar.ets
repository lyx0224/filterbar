import display from '@ohos.display';
import {
  CallBackData,
  AbsFilterData,
  SingleFilterData,
  TwoListFilterData,
  FilterItemData,
  TwoListLeftData,
} from './model';

@Component
export struct FilterBar {
  @Prop filterDataList: AbsFilterData[]
  callback?: (data: CallBackData) => void
  @State popStatus: boolean[] = []
  private _offset: Position[] = []
  @State tabTitleList: string[] = []
  @State tabTitleColor: Resource[] = []
  private itemTabWidth = -1

  aboutToAppear(): void {
    this.filterDataList.forEach((item, index) => {
      this.popStatus[index] = false
      this._offset[index] = { x: 0, y: 0 }
      this.tabTitleList[index] = item.tabTitle
      this.tabTitleColor[index] = $r('app.color.fb_normal_color')
      this.itemTabWidth = getScreenWidth() / this.filterDataList.length
    })
  }

  build() {
    Row() {
      ForEach(this.filterDataList, (item: AbsFilterData, index: number) => {
        TabItem(
          {
            title: this.tabTitleList[index],
            pop: this.popStatus[index],
            color: this.tabTitleColor[index],
            tabClick: () => {
              this._offset[index] = {
                x: ((this.filterDataList.length / 2) - 0.5 - index) * this.itemTabWidth,
                y: 0
              }
              this.popStatus[index] = !this.popStatus[index]
            }
          }
        ).layoutWeight(1)
          .bindPopup(this.popStatus[index], {
            placement: Placement.Bottom,
            enableArrow: false,
            offset: this._offset[index],
            onStateChange: (event) => {
              if (!event.isVisible) {
                this.popStatus[index] = false
              }
            },
            builder:
            item instanceof SingleFilterData ?
            this.singlePopupBuilder(item.isGrid, index, item as SingleFilterData) :
            this.twoListPopupWindowBuilder(item as TwoListFilterData, (leftIndex: number, rightData: FilterItemData) => {
              this.popStatus[index] = false
              this.updateTabStatus(index, rightData.title)
              if (this.callback) {
                this.callback(new CallBackData(index, leftIndex, rightData))
              }
            })
          })
      })
    }
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Center)
    .width('100%')
  }

  updateTabStatus(tabIndex: number, value: string) {
    if (value == '不限') {
      this.tabTitleColor[tabIndex] = $r('app.color.fb_normal_color')
      this.tabTitleList[tabIndex] = this.filterDataList[tabIndex].tabTitle
    } else {
      this.tabTitleColor[tabIndex] = $r('app.color.fb_primary_color')
      this.tabTitleList[tabIndex] = value
    }
  }

  @Builder
  singlePopupBuilder(isGrid: boolean, tabIndex: number, filterData: SingleFilterData) {
    if (isGrid) {
      GridView({ filterData: filterData, callback: (itemData: FilterItemData, itemIndex: number) => {
        this.popStatus[tabIndex] = false
        this.updateTabStatus(tabIndex, itemData.title)
        if (this.callback) {
          this.callback(new CallBackData(tabIndex, -1, itemData))
        }
      } })
    } else {
      SingleListView({ filterData: filterData, callback: (itemData: FilterItemData, itemIndex: number) => {
        this.popStatus[tabIndex] = false
        this.updateTabStatus(tabIndex, itemData.title)
        if (this.callback) {
          this.callback(new CallBackData(tabIndex, -1, itemData))
        }
      } })
    }

  }

  @Builder
  twoListPopupWindowBuilder(filterData: TwoListFilterData, cb: (leftIndex: number, rightData: FilterItemData) => void) {
    TwoListView({ filterData: filterData, callback: cb })
  }

  @Builder
  gridPopupBuilder(filterData: SingleFilterData) {
    GridView({ filterData: filterData })
  }
}

@Component
struct SingleListView {
  @Prop filterData: SingleFilterData
  callback?: (item: FilterItemData, index: number) => void
  @State currentIndex: number = 0

  build() {
    Column() {
      List({ space: 5 }) {
        ForEach(this.filterData.popupData, (item: FilterItemData, index: number) => {
          ListItem() {
            Column() {
              Text(`${item.title}`)
                .textAlign(TextAlign.Center)
                .width('100%')
                .height('40vp')
                .fontSize('16fp')
                .fontColor(this.currentIndex == index ? $r('app.color.fb_primary_color') : $r('app.color.fb_normal_color'))
                .onClick(() => {
                  this.currentIndex = index
                  if (this.callback) {
                    this.callback(item, index)
                  }
                })
              Divider()
            }
          }
        })
      }
    }
    .constraintSize({ minHeight: '20%', maxHeight: '50%' })
    .backgroundColor(Color.White)
    .width('100%')
  }
}

@Component
struct TwoListView {
  @Prop filterData: TwoListFilterData
  @State leftIndex: number = -1
  //用于区分rightCurrentIndex属于哪个leftIndex
  private rightCurrentLeftIndex: number = 0
  @State rightCurrentIndex: number = 0
  callback?: (leftIndex: number, rightData: FilterItemData) => void

  aboutToAppear(): void {
    if (this.filterData.popupData.length > 0) {
      this.leftIndex = 0
    }
  }

  build() {
    Row() {
      //左list
      List() {
        ForEach(this.filterData.popupData, (leftItem: TwoListLeftData, index: number) => {
          ListItem() {
            Column() {
              Text(`${leftItem.leftTitle}`)
                .textAlign(TextAlign.Center)
                .width('100%')
                .height('40vp')
                .fontSize('16fp')
                .fontColor(this.leftIndex == index ? $r('app.color.fb_primary_color') : $r('app.color.fb_normal_color'))
                .onClick(() => {
                  this.leftIndex = index
                })
              Divider()
            }
          }
        })
      }.layoutWeight(1)

      //右List
      if (this.leftIndex >= 0 && this.leftIndex < this.filterData.popupData.length) {
        List() {
          ForEach(this.filterData.popupData[this.leftIndex].items, (item: FilterItemData, index: number) => {
            ListItem() {
              Column() {
                Text(`${item.title}`)
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .height('40vp')
                  .fontSize('16fp')
                  .fontColor((this.rightCurrentIndex == index && this.rightCurrentLeftIndex == this.leftIndex) ? $r('app.color.fb_primary_color') : $r('app.color.fb_normal_color'))
                  .onClick(() => {
                    // 更新ui
                    this.rightCurrentLeftIndex = this.leftIndex
                    this.rightCurrentIndex = index
                    if (this.callback) {
                      this.callback(this.leftIndex, item)
                    }
                  })
                Divider()
              }
              .justifyContent(FlexAlign.Start)
            }
          })
        }.layoutWeight(1).backgroundColor('#E5E9F4')
      }
    }
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Top)
    .width('100%')
  }
}

@Component
struct GridView {
  @Prop filterData: SingleFilterData
  callback?: (item: FilterItemData, index: number) => void
  @State currentIndex: number = 0

  build() {
    Column() {
      Grid() {
        ForEach(this.filterData.popupData, (item: FilterItemData, index: number) => {
          GridItem() {
            Text(`${item.title}`)
              .textAlign(TextAlign.Center)
              .fontSize('16fp')
              .border({
                radius: '4vp',
                color: this.currentIndex == index ? $r('app.color.fb_grid_select_border_color') : $r('app.color.fb_grid_border_color'),
                width: 0.5
              })
              .backgroundColor(this.currentIndex == index ? $r('app.color.fb_grid_bg_color') : Color.White)
              .fontColor(this.currentIndex == index ? $r('app.color.fb_primary_color') : $r('app.color.fb_normal_color'))
              .height('40vp')
              .width('100%')
          }.onClick(() => {
            this.currentIndex = index
            if (this.callback) {
              this.callback(item, index)
            }
          })
        })
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap('16vp')
      .columnsGap('16vp')
      .margin({ left: '16vp', right: '16vp', top: '16vp', bottom: '16vp' })
      .layoutDirection(GridDirection.Row)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .constraintSize({
      minHeight: '20%',
      maxHeight: '20%'//grid会撑满maxHeight，先限定死高度
    })
  }
}

@Component
export struct TabItem {
  @Prop pop: boolean
  @Prop color: Resource
  tabClick: () => void = () => {
  }
  @Prop title: string

  build() {
    Row() {
      Text(this.title)
        .fontSize('18vp')
        .fontColor(this.pop ? $r('app.color.fb_primary_color') : this.color)
      Blank().width('4vp')
      if (this.pop) {
        Image($r('app.media.comm_page_icon_jt_s')).size({ width: '12vp', height: '7vp' })
      } else {
        Image($r('app.media.comm_page_icon_jt_x')).size({ width: '12vp', height: '7vp' })
      }
    }
    .width('100%')
    .height('40vp')
    .onClick(this.tabClick)
    .justifyContent(FlexAlign.Center)
  }
}

function getScreenWidth(): number {
  try {
    let displayClass = display.getDefaultDisplaySync();
    return px2vp(displayClass.width);
  } catch (exception) {
    console.error('Failed to obtain the default display object. Code: ' + JSON.stringify(exception));
  }
  return 0;
}