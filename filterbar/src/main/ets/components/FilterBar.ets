import display from '@ohos.display';

@Component
export struct FilterBar {
  @Prop filterDataList: FilterData[]
  callback?: (data: CallBackData) => void
  @State popStatus: boolean[] = []
  private _offset: Position[] = []
  @State tabTitleList: string[] = []
  private itemTabWidth = -1

  aboutToAppear(): void {
    this.filterDataList.forEach((item, index) => {
      this.popStatus[index] = false
      this._offset[index] = { x: 0, y: 0 }
      this.tabTitleList[index] = item.title
      this.itemTabWidth = getScreenWidth() / this.filterDataList.length
    })
  }

  build() {
    Row() {
      ForEach(this.filterDataList, (item: FilterData, index: number) => {
        TabItem(
          {
            title: this.tabTitleList[index],
            pop: this.popStatus[index],
            tabClick: () => {
              this.popStatus[index] = !this.popStatus[index]
            },
            touchCallback: () => {
              this._offset[index] = {
                x: (1.5 - index) * this.itemTabWidth,
                y: 0
              }
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
            this.singlePopupBuilder(item as SingleFilterData, (v: string, i: number) => {
              this.popStatus[index] = false
              this.updateTabTitle(index, v)
              if (this.callback) {
                this.callback(new CallBackData(index, i, v))
              }
            }) :
            this.twoListPopupWindowBuilder(item as TwoListFilterData, (item: string, index: number, item2: string, index2: string) => {

            })
          })
      })
    }
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Center)
    .width('100%')
  }

  updateTabTitle(tabIndex: number, value: string) {
    if (value == '不限') {
      this.tabTitleList[tabIndex] = this.filterDataList[tabIndex].title
    } else {
      this.tabTitleList[tabIndex] = value
    }
  }

  @Builder
  singlePopupBuilder(filterData: SingleFilterData, cb: (item: string, index: number) => void) {
    Column() {
      List({ space: 5 }) {
        ForEach(filterData.popupData, (item: string, index: number) => {
          ListItem() {
            Column() {
              Text(`${item}`)
                .textAlign(TextAlign.Center)
                .width('100%')
                .height('40vp')
                .fontSize('16fp')
                .fontColor('#333333')
                .onClick(() => {
                  cb(item, index)
                })
              Divider()
            }

          }
        })
      }
    }
    .backgroundColor(Color.White)
    .width('100%')
  }

  @Builder
  twoListPopupWindowBuilder(tabData: TwoListFilterData, cb: (item: string, index: number, item2: string, index2: string) => void) {
    Row() {
      Text('todo')
      // List() {
      //
      // }.layoutWeight(1)
      //
      // ///第二个list
      // List() {
      //
      // }.layoutWeight(1)
    }
    .width('100%')
    .backgroundColor(Color.White)
  }
}

@Component
export struct TabItem {
  @Prop pop: boolean
  tabClick: () => void = () => {
  }
  touchCallback: () => void = () => {
  }
  @Prop title: string

  build() {
    Row() {
      Text(this.title)
        .fontSize('18vp')
        .fontColor(this.pop ? '#ff8700' : '#333333')
      if (this.pop) {
        Text('👆🏻')
      } else {
        Text('👇🏻')
      }
    }
    .width('100%')
    .height('40vp')
    .onTouch((event: TouchEvent) => {
      if (event.type == TouchType.Down) {
        this.touchCallback()
      }
    })
    .onClick(this.tabClick)
    .justifyContent(FlexAlign.Center)
  }
}

export class CallBackData {
  tabIndex: number
  valueIndex: number
  data: string

  constructor(tabIndex: number, valueIndex: number, data: string) {
    this.tabIndex = tabIndex
    this.valueIndex = valueIndex
    this.data = data
  }
}

export enum TabContentType {
  SINGLE_LIST,
  TOW_LIST,
  GRID
}

export abstract class FilterData {
  title: string
  checked: boolean

  constructor(title: string, checked: boolean) {
    this.title = title
    this.checked = checked
  }
}

///单列数据源
export class SingleFilterData extends FilterData {
  popupData: string[]

  constructor(title: string, popupData: string[]) {
    super(title, false)
    this.popupData = popupData
  }
}

///双列数据源
export class TwoListFilterData extends FilterData {
  popupData: string[][]

  constructor(title: string, popupData: string[][]) {
    super(title, false)
    this.popupData = popupData
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