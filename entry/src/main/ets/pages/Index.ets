import ArrayList from '@ohos.util.ArrayList'
import promptAction from '@ohos.promptAction'
import { SingleFilterData, TwoListFilterData, FilterBar, FilterData } from '@liyixin/filterbar'

@Entry
@Component
struct Index {
  private dataList: ArrayList<FilterData> = new ArrayList()

  aboutToAppear(): void {
    this.dataList.add(new SingleFilterData('区域', ['不限', '宝山区', '崇明区', '长宁区', '普陀区', '嘉定区', '松江区', '静安区']))
    this.dataList.add(new SingleFilterData('价格', ['200万以下', '200-250万', '250-300万', '300-400万', '400-500万']))
    this.dataList.add(new SingleFilterData('房型', ['1室', '2室', '3室', '4室', '5室及以上']))
    this.dataList.add(new TwoListFilterData('板块', [
      ['xx', 'xx'],
      ['xx', 'xxx']
    ]))
  }

  build() {
    Column() {
      FilterBar({
        filterDataList: this.dataList.convertToArray(),
        callback: (data) => {
          promptAction.showToast({
            message: `tabIndex:${data.tabIndex}, valueIndex: ${data.valueIndex}, value: ${data.data}`
          })
        }
      }).margin({ left: 0, right: 0, top: 20 })
    }
    .height('100%')
    .width('100%')
  }
}