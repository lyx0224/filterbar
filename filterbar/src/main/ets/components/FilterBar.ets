import display from '@ohos.display';
import {
  CallBackData,
  AbsFilterData,
  SingleFilterData,
  TwoListFilterData,
  TwoListLeftData,
  IFilterItemData,
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
            this.twoListPopupWindowBuilder(item as TwoListFilterData, (leftIndex: number, rightData: IFilterItemData) => {
              this.popStatus[index] = false
              this.updateTabStatus(index, rightData.getShownTitle())
              if (this.callback) {
                this.callback(new CallBackData(index, [rightData]))
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
      GridView({ filterData: filterData, callback: (itemDataList: IFilterItemData[]) => {
        this.popStatus[tabIndex] = false
        if (itemDataList.length == 1) {
          this.updateTabStatus(tabIndex, itemDataList[0].getShownTitle())
        } else {
          this.updateTabStatus(tabIndex, '多选')
        }
        if (this.callback) {
          this.callback(new CallBackData(tabIndex, itemDataList))
        }
      } })
    } else {
      SingleListView({ filterData: filterData, callback: (itemData: IFilterItemData, itemIndex: number) => {
        this.popStatus[tabIndex] = false
        this.updateTabStatus(tabIndex, itemData.getShownTitle())
        if (this.callback) {
          this.callback(new CallBackData(tabIndex, [itemData]))
        }
      } })
    }

  }

  @Builder
  twoListPopupWindowBuilder(filterData: TwoListFilterData, cb: (leftIndex: number, rightData: IFilterItemData) => void) {
    TwoListView({ filterData: filterData, callback: cb })
  }
}

@Component
struct SingleListView {
  @Prop filterData: SingleFilterData
  callback?: (item: IFilterItemData, index: number) => void
  @State currentIndex: number = 0

  build() {
    Column() {
      List({ space: 5 }) {
        ForEach(this.filterData.popupData, (item: IFilterItemData, index: number) => {
          ListItem() {
            Column() {
              Text(`${item.getShownTitle()}`)
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
  callback?: (leftIndex: number, rightData: IFilterItemData) => void

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
          ForEach(this.filterData.popupData[this.leftIndex].items, (item: IFilterItemData, index: number) => {
            ListItem() {
              Column() {
                Text(`${item.getShownTitle()}`)
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
  callback?: (itemList: IFilterItemData[]) => void
  @State currentIndexList: Array<number> = []

  contain(src: number): boolean {
    return this.currentIndexList.indexOf(src) >= 0
  }

  build() {
    Column() {
      // 网格
      Grid() {
        ForEach(this.filterData.popupData, (item: IFilterItemData, index: number) => {
          GridItem() {
            Text(`${item.getShownTitle()}`)
              .textAlign(TextAlign.Center)
              .fontSize('16fp')
              .border({
                radius: '4vp',
                color: this.contain(index) ? $r('app.color.fb_grid_select_border_color') : $r('app.color.fb_grid_border_color'),
                width: 0.5
              })
              .backgroundColor(this.contain(index) ? $r('app.color.fb_grid_bg_color') : Color.White)
              .fontColor(this.contain(index) ? $r('app.color.fb_primary_color') : $r('app.color.fb_normal_color'))
              .height('40vp')
              .width('100%')
          }.onClick(() => {
            //单选
            if (this.filterData.isSingleChoice) {
              this.currentIndexList = []
              this.currentIndexList.push(index)
              if (this.callback) {
                this.callback([item])
              }
            } else {
              //多选
              let p = this.currentIndexList.indexOf(index)
              if (p == -1) {
                this.currentIndexList.push(index)
              } else {
                this.currentIndexList.splice(p, 1)
              }
            }
          })
        })
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap('16vp')
      .columnsGap('16vp')
      .margin({ left: '16vp', right: '16vp', top: '16vp', bottom: '16vp' })
      .layoutDirection(GridDirection.Row)
      .constraintSize({
        minHeight: '20%',
        maxHeight: '20%'//grid会撑满maxHeight，先限定死高度
      })

      //底部按钮
      if (!this.filterData.isSingleChoice) {
        Row() {
          Button('重置')
            .secondBtn()
            .onClick(() => {
              this.currentIndexList = []
            })
          Blank().layoutWeight(1)
          Button('确认').primaryBtn().onClick(() => {
            let newList = this.filterData.popupData.filter((_, index, __) => {
              return this.contain(index)
            })
            if (this.callback) {
              this.callback(newList)
            }
          })
        }
        .margin('16vp')
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
  }
}

@Extend(Button)
function primaryBtn() {
  .border({
    radius: 2,
  })
  .fontSize('16fp')
  .fontColor(Color.White)
  .backgroundColor($r('app.color.fb_primary_color'))
}

@Extend(Button)
function secondBtn() {
  .border({
    radius: 2,
    width: 0.5,
    color: $r('app.color.fb_grid_select_border_color')
  })
  .fontSize('16fp')
  .fontColor($r('app.color.fb_primary_color'))
  .backgroundColor(Color.White)
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