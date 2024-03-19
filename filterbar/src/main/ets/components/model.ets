class CallBackData {
  tabIndex: number
  leftIndex?: number //双列有效
  itemData: FilterItemData

  constructor(tabIndex: number, leftIndex: number, itemData: FilterItemData) {
    this.tabIndex = tabIndex
    this.leftIndex = leftIndex
    this.itemData = itemData
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
  constructor(tabTitle: string, isGrid: boolean, popupData: FilterItemData[]) {
    super(tabTitle)
    this.isGrid = isGrid
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