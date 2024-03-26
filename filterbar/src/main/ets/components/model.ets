class CallBackData {
  tabIndex: number
  itemDataList: IFilterItemData[]

  constructor(tabIndex: number, itemDataList: IFilterItemData[]) {
    this.tabIndex = tabIndex
    this.itemDataList = itemDataList
  }
}

interface IFilterItemData {
  getShownTitle(): string
}

class FilterItemData implements IFilterItemData {
  // checked: boolean
  private title: string

  constructor(title: string) {
    this.title = title
    // this.checked = false
  }

  getShownTitle(): string {
    return this.title
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
  popupData: IFilterItemData[]
  isGrid: boolean
  isSingleChoice: boolean

  constructor(tabTitle: string, isGrid: boolean, isSingleChoice: boolean, popupData: IFilterItemData[]) {
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
  items: IFilterItemData[]

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

export { SingleFilterData,
  TwoListFilterData,
  AbsFilterData,
  FilterItemData,
  TwoListLeftData,
  CallBackData,
  IFilterItemData }