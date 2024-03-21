import ArrayList from '@ohos.util.ArrayList'
import promptAction from '@ohos.promptAction'
import {
  SingleFilterData,
  TwoListFilterData,
  TwoListLeftData,
  FilterBar,
  AbsFilterData,
  FilterItemData,
} from '@liyixin/filterbar'

@Entry
@Component
struct Index {
  private dataList: ArrayList<AbsFilterData> = new ArrayList()

  aboutToAppear(): void {
    ///宝山
    let tabList1: FilterItemData[] = []
    tabList1[0] = new FilterItemData('不限')
    tabList1[1] = new FilterItemData('大华')
    tabList1[2] = new FilterItemData('顾村')
    tabList1[3] = new FilterItemData('通河')
    tabList1[4] = new FilterItemData('淞宝')
    tabList1[5] = new FilterItemData('杨航')
    ///黄浦区
    let tabList4: FilterItemData[] = []
    tabList4[0] = new FilterItemData('不限')
    tabList4[1] = new FilterItemData('打浦桥')
    tabList4[2] = new FilterItemData('董家渡')
    tabList4[3] = new FilterItemData('淮海中路')
    tabList4[4] = new FilterItemData('人民广场')
    tabList4[5] = new FilterItemData('世博滨江')
    tabList4[6] = new FilterItemData('新天地')

    ///双列
    let twoListItemDataList: TwoListLeftData[] = []
    twoListItemDataList[1] = new TwoListLeftData('黄浦区', tabList4)
    twoListItemDataList[0] = new TwoListLeftData('宝山区', tabList1)
    this.dataList.add(new TwoListFilterData('区域', twoListItemDataList))

    //单列表
    let tabList2: FilterItemData[] = []
    tabList2[0] = new FilterItemData('不限')
    tabList2[1] = new FilterItemData('200万以下')
    tabList2[2] = new FilterItemData('200-250万')
    tabList2[3] = new FilterItemData('250-300万')
    tabList2[4] = new FilterItemData('300-400万')
    tabList2[5] = new FilterItemData('400-500万')
    this.dataList.add(new SingleFilterData('价格', false, true, tabList2))

    //网格
    let tabList3: FilterItemData[] = []
    tabList3[0] = new FilterItemData('1室')
    tabList3[1] = new FilterItemData('2室')
    tabList3[2] = new FilterItemData('3室')
    tabList3[3] = new FilterItemData('4室')
    tabList3[4] = new FilterItemData('5+室')
    this.dataList.add(new SingleFilterData('房型', true, false, tabList3))
    //单列表
    let tabList5: FilterItemData[] = []
    tabList5[0] = new FilterItemData('不限')
    tabList5[1] = new FilterItemData('智能排序')
    tabList5[2] = new FilterItemData('最新挂牌')
    this.dataList.add(new SingleFilterData('房源库', true, true, tabList5))
  }

  build() {
    Column() {
      FilterBar({
        filterDataList: this.dataList.convertToArray(),
        callback: (data) => {
          promptAction.showToast({
            message: `tabIndex:${data.tabIndex}, value: ${data.itemDataList.map((v) => v.title).join(',')}`
          })
        }
      }).margin({ left: 0, right: 0, top: 20 })
    }
    .height('100%')
    .width('100%')
  }
}