import { OverviewData } from '../../model/i';

@Component
export struct Workbench {
  // 主题色常量
  readonly themeColor: string = '#1890FF';
  readonly cardBgColor: string = '#FFFFFF';
  readonly textColor: string = '#000000';
  readonly textColorSecondary: string = 'rgba(0, 0, 0, 0.65)';

  // 统计卡片数据
  @State overviewData: OverviewData[] = [
    { title: '访问量', value: '2,000', total: '120,000', icon: '/common/images/ic_public_add.svg' },
    { title: '成交额', value: '20,000', total: '500,000', icon: '/common/images/ic_public_add.svg' },
    { title: '下载数', value: '8,000', total: '120,000', icon: '/common/images/ic_public_add.svg' },
    { title: '成交数', value: '5,000', total: '50,000', icon: '/common/images/ic_public_add.svg' }
  ]

  build() {
    Column() {
      // 概览卡片
      Grid() {
        ForEach(this.overviewData, (item: OverviewData) => {
          GridItem() {
            Column() {
              Row() {
                Column() {
                  Text(item.title)
                    .fontSize(14)
                    .fontColor(this.textColorSecondary)
                    .margin({ bottom: 4 })
                  Text(item.value)
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.textColor)
                  Text(`总${item.title} ${item.total}`)
                    .fontSize(12)
                    .fontColor(this.textColorSecondary)
                    .margin({ top: 8 })
                }
                .alignItems(HorizontalAlign.Start)

                Image(item.icon)
                  .width(48)
                  .height(48)
                  .opacity(0.8)
                  .fillColor(this.themeColor)
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Top)
            }
            .padding(24)
            .backgroundColor(this.cardBgColor)
            .borderRadius(8)
          }
        }, (item: OverviewData) => item.title)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(16)
      .rowsGap(16)
      .width('100%')
      .margin({ bottom: 24 })

      // 图表区域
      // Grid() {
      //   // 访问趋势
      //   GridItem() {
      //     Column() {
      //       Text('访问趋势')
      //         .fontSize(16)
      //         .fontWeight(FontWeight.Medium)
      //         .fontColor(this.textColor)
      //         .margin({ bottom: 16 })
      //       // 图表占位
      //       Row() {
      //         Column() {
      //           Text('暂无数据')
      //             .fontSize(14)
      //             .fontColor(this.textColorSecondary)
      //         }
      //         .width('100%')
      //         .height('100%')
      //         .justifyContent(FlexAlign.Center)
      //       }
      //       .width('100%')
      //       .height(300)
      //       .backgroundColor(this.cardBgColor)
      //       .borderRadius(4)
      //     }
      //     .width('100%')
      //     .padding(24)
      //     .backgroundColor(this.cardBgColor)
      //     .borderRadius(8)
      //   }
      //   .columnStart(0)
      //   .columnEnd(1)
      //
      //   // 转化率
      //   GridItem() {
      //     Column() {
      //       Text('转化率')
      //         .fontSize(16)
      //         .fontWeight(FontWeight.Medium)
      //         .fontColor(this.textColor)
      //         .margin({ bottom: 16 })
      //       // 图表占位
      //       Row() {
      //         Column() {
      //           Text('暂无数据')
      //             .fontSize(14)
      //             .fontColor(this.textColorSecondary)
      //         }
      //         .width('100%')
      //         .height('100%')
      //         .justifyContent(FlexAlign.Center)
      //       }
      //       .width('100%')
      //       .height(300)
      //       .backgroundColor(this.cardBgColor)
      //       .borderRadius(4)
      //     }
      //     .width('100%')
      //     .padding(24)
      //     .backgroundColor(this.cardBgColor)
      //     .borderRadius(8)
      //   }
      //   .columnStart(1)
      //   .columnEnd(2)
      // }
      // .columnsTemplate('1fr 1fr')
      // .columnsGap(16)
      // .rowsGap(16)
      // .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(24)
  }
}
