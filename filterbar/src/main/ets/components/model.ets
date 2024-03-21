class CallBackData {
  tabIndex: number
  itemDataList: FilterItemData[]

  constructor(tabIndex: number, itemDataList: FilterItemData[]) {
    this.tabIndex = tabIndex
    this.itemDataList = itemDataList
  }
}

class FilterItemData {
  // checked: boolean
  title: string

  constructor(title: string) {
    this.title = title
    // this.checked = false
  }
}

abstract class AbsFilterData {
  tabTitle: string

  constructor(tabTitle: string) {
    this.tabTitle = tabTitle
  }
}

///单列数据源
class SingleFilterData extends AbsFilterData {
  popupData: FilterItemData[]
  isGrid: boolean
  isSingleChoice: boolean

  constructor(tabTitle: string, isGrid: boolean, isSingleChoice: boolean, popupData: FilterItemData[]) {
    super(tabTitle)
    this.isGrid = isGrid
    if (isGrid) {
      this.isSingleChoice = isSingleChoice
    } else {
      this.isSingleChoice = true
    }
    this.popupData = popupData
  }
}

class TwoListLeftData {
  leftTitle: string
  items: FilterItemData[]

  constructor(leftTitle: string, items: FilterItemData[]) {
    this.leftTitle = leftTitle
    this.items = items
  }
}

///双列数据源
class TwoListFilterData extends AbsFilterData {
  popupData: TwoListLeftData[]

  constructor(tabTitle: string, popupData: TwoListLeftData[]) {
    super(tabTitle)
    this.popupData = popupData
  }
}

export { SingleFilterData, TwoListFilterData, AbsFilterData, FilterItemData, TwoListLeftData, CallBackData }