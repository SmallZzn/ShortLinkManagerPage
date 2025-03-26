import { JhProgressHUD } from '../../JhCommon/components/JhProgressHUD';
import { APIs } from '../../JhCommon/http/APIs';
import { HttpUtils } from '../../JhCommon/http/HttpUtils';
import { JhAESPreferencesUtils } from '../../JhCommon/utils/JhPreferencesUtils';
import { ShortLink, ShortLinkStatsData } from '../../model/ShortLinkInterface';
import router from '@ohos.router';
import { OsStatsList } from '../ShortLinkPage/statistics/OsStatsList';
import { BrowserStatsList } from '../ShortLinkPage/statistics/BrowserStatsList';
import { HighFreqIpList } from '../ShortLinkPage/statistics/HighFreqIpList';
import { UvTypeStatsList } from '../ShortLinkPage/statistics/UvTypeStatsList';
import { NetworkStatsList } from '../ShortLinkPage/statistics/NetworkStatsList';
import { DeviceStatsList } from '../ShortLinkPage/statistics/DeviceStatsList';
import { HighIp } from '../ShortLinkPage/statistics/HighIp';

interface SelectOption {
  value: string;
  text: string;
}

@Component
export struct UserStats {
  // 主题色常量
  readonly themeColor: string = '#4080FF';
  readonly themeColorLight: string = '#F2F3F5';
  readonly textColor: string = '#1D2129';
  readonly textColorSecondary: string = '#86909C';
  readonly themeBorderColor: string = '#E5E6EB';

  // 数据状态
  @State userList: Array<string> = [];
  @State selectedUser: string = '';
  @State selectedUserIndex: number = 0;
  @State startDate: string = '';
  @State endDate: string = '';
  @State selectedStartDate: Date = new Date(new Date().setDate(new Date().getDate() - 7));
  @State selectedEndDate: Date = new Date();
  @State statsData: ShortLinkStatsData | null = null;
  @State updateCounter: number = 0;
  @State shortLink: ShortLink | null = null;

  aboutToAppear() {
    // 初始化 UI 上下文
    let uiContext: UIContext = this.getUIContext() as UIContext;
    JhProgressHUD.initUIConfig(uiContext);

    // 设置默认日期范围为近七天
    this.selectedEndDate = new Date(); // 今天
    this.selectedStartDate = new Date(new Date().setDate(new Date().getDate() - 7)); // 七天前
    this.endDate = this.formatDate(this.selectedEndDate);
    this.startDate = this.formatDate(this.selectedStartDate);

    // 获取路由参数
    const params = router.getParams() as Record<string, ShortLink>;
    if (params && params.shortLink) {
      this.shortLink = params.shortLink;
      this.selectedUser = this.shortLink.gid;
      // 获取统计数据
      this.fetchStatsData();
    } else {
      // 如果没有传入短链接，则获取下拉框数据
      this.fetchUserList();
    }
  }

  // 获取下拉框数据
  private async fetchUserList() {
    try {
      const manager: string = JhAESPreferencesUtils.getString("username") || '';
      const res = await HttpUtils.get(APIs.listByManagerName + manager, {});
      if (res.code === '0') {
        this.userList = res.data;
        if (this.userList.length > 0) {
          this.selectedUser = this.userList[0];
          this.selectedUserIndex = 0;
          // 获取统计数据
          this.fetchStatsData();
        }
      } else {
        JhProgressHUD.showError('获取数据失败');
      }
    } catch (error) {
      console.error('获取数据失败:', error);
      JhProgressHUD.showError('获取数据失败');
    }
  }

  // 获取统计数据
  private async fetchStatsData() {
    try {
      console.info(`[用户信息统计] 开始获取统计数据，API: ${APIs.groupShortLinkStatsUser}`);

      // 检查是否选择了用户
      if (!this.selectedUser) {
        JhProgressHUD.showError('请先选择用户/公司');
        return;
      }

      // 定义请求参数接口
      interface StatsRequestParams {
        startDate: string;
        endDate: string;
        size: number;
        count: number;
        username: string;
      }

      // 构建请求参数
      const params: StatsRequestParams = {
        startDate: this.formatDateTime(new Date(this.startDate), true),
        endDate: this.formatDateTime(new Date(this.endDate), false),
        size: 10,
        count: 1,
        username: this.selectedUser  // 使用下拉框选择的用户名
      };

      console.info(`[用户信息统计] 请求参数: ${JSON.stringify(params)}`);

      const res = await HttpUtils.post(APIs.groupShortLinkStatsUser, params);
      console.info(`[用户信息统计] 响应结果: ${JSON.stringify(res)}`);

      if (res.code === '0') {
        // 设置数据
        this.statsData = res.data;
        
        // 隐藏加载提示
        JhProgressHUD.hide();
        
        // 更新计数器，触发图表更新
        this.updateCounter++;
        console.info(`[用户信息统计] 更新计数器，新值: ${this.updateCounter}`);
      } else {
        // 显示错误提示
        console.error(`[用户信息统计] 获取数据失败: ${res.message}`);
        JhProgressHUD.showError('获取统计数据失败');
      }
    } catch (error) {
      console.error('获取统计数据失败:', error);
      JhProgressHUD.showError('获取统计数据失败');
    }
  }

  // 格式化日期
  private formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  // 格式化日期（添加时分秒）
  private formatDateTime(date: Date, isStart: boolean = true): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    // 开始时间设为当天 00:00:00，结束时间设为当天 23:59:59
    const time = isStart ? '00:00:00' : '23:59:59';
    return `${year}-${month}-${day} ${time}`;
  }

  build() {
    Column() {
      // 标题
      Text('用户信息')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.textColor)
        .margin({ bottom: 10 })
        .alignSelf(ItemAlign.Start)

      // 操作栏
      Row() {
        // 用户/公司下拉框
        Text('用户/公司:')
          .fontSize(14)
          .fontColor(this.textColor)
          .margin({ right: 5 })
          .alignSelf(ItemAlign.Center)

        Select(this.userList.map(item => {
          const option: SelectOption = {
            value: item,
            text: item
          };
          return option;
        }))
          .selected(this.selectedUserIndex)
          .value(this.selectedUser)
          .font({ size: 14, weight: 400 })
          .fontColor(this.textColor)
          .selectedOptionFont({ size: 14, weight: 400 })
          .optionFont({ size: 14, weight: 400 })
          .space(8)
          .arrowPosition(ArrowPosition.END)
          .menuAlign(MenuAlignType.END, { dx: 0, dy: 0 })
          .optionWidth(150)
          .optionHeight(240)
          .width(200)
          .height(36)
          .backgroundColor(Color.White)
          .borderRadius(2)
          .border({ width: 1, color: this.themeBorderColor })
          .onSelect((index: number) => {
            this.selectedUserIndex = index;
            this.selectedUser = this.userList[index];
            this.fetchStatsData();
          })
          .margin({ right: 12 })
          .enabled(!this.shortLink) // 如果有短链接数据，禁用下拉框

        // 日期选择器和搜索按钮
        Row({ space: 8 }) {
          // 开始日期
          Row() {
            Text(this.startDate || '点击选择日期')
              .fontSize(14)
              .fontColor(this.startDate ? this.textColor : this.textColorSecondary)
          }
          .width(100)
          .height(32)
          .backgroundColor(this.themeColorLight)
          .borderRadius(4)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            CalendarPickerDialog.show({
              selected: this.selectedStartDate || new Date(),
              onAccept: (value: Date) => {
                // 验证日期范围：开始日期不能晚于结束日期
                if (this.endDate) {
                  // 使用年月日进行比较，而不是直接比较Date对象
                  const startDateStr = this.formatDate(value);
                  if (startDateStr > this.endDate) {
                    JhProgressHUD.showText('开始日期不能晚于结束日期');
                    return;
                  }
                }

                this.selectedStartDate = value;
                this.startDate = this.formatDate(this.selectedStartDate);
              }
            })
          })

          Text('至')
            .fontSize(14)
            .fontColor(this.textColor)

          // 结束日期
          Row() {
            Text(this.endDate || '点击选择日期')
              .fontSize(14)
              .fontColor(this.endDate ? this.textColor : this.textColorSecondary)
          }
          .width(100)
          .height(32)
          .backgroundColor(this.themeColorLight)
          .borderRadius(4)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            CalendarPickerDialog.show({
              selected: this.selectedEndDate || new Date(),
              onAccept: (value: Date) => {
                // 验证日期范围：结束日期不能早于开始日期
                if (this.startDate) {
                  // 使用年月日进行比较，而不是直接比较Date对象
                  const endDateStr = this.formatDate(value);
                  if (endDateStr < this.startDate) {
                    JhProgressHUD.showText('结束日期不能早于开始日期');
                    return;
                  }
                }

                this.selectedEndDate = value;
                this.endDate = this.formatDate(this.selectedEndDate);
              }
            })
          })

          // 搜索按钮
          Button() {
            Row({ space: 4 }) {
              Image($r('app.media.select'))
                .width(16)
                .height(16)
                .objectFit(ImageFit.Contain)
              Text('搜索')
                .fontSize(14)
                .fontColor(Color.White)
            }
          }
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor(this.themeColor)
          .borderRadius(4)
          .height(32)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            // 显示加载提示
            JhProgressHUD.showLoadingText('正在查询...');
            console.info(`[用户信息统计] 点击搜索按钮，日期范围: ${this.startDate} 至 ${this.endDate}`);
            
            // 查询数据
            this.fetchStatsData();
          })
        }
      }
      .width('100%')
      .margin({ bottom: 12 })
      .justifyContent(FlexAlign.Start)

      // 统计图表区域
      Scroll() {
        Column() {
          // 第一行：操作系统和浏览器
          Row() {
            // 操作系统统计
            Column() {
              Text('操作系统')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.textColor)
                .margin({ bottom: 16 })

              OsStatsList({
                osStats: this.statsData?.osStats || []
              })
            }
            .width('100%')
            .height(300)
            .padding(24)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .border({ width: 1, color: this.themeBorderColor })
            .layoutWeight(1)
            .margin({ right: 8 })

            // 浏览器统计
            Column() {
              Text('浏览器')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.textColor)
                .margin({ bottom: 16 })

              BrowserStatsList({
                browserStats: this.statsData?.browserStats || []
              })
            }
            .width('100%')
            .height(300)
            .padding(24)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .border({ width: 1, color: this.themeBorderColor })
            .layoutWeight(1)
            .margin({ left: 8 })
          }
          .width('100%')
          .margin({ bottom: 16 })

          // 第二行：高频IP和访客类型
          Row() {
            // 高频IP统计
            Column() {
              Text('高频IP')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.textColor)
                .margin({ bottom: 16 })

              HighIp({
                ipStats: this.statsData?.topIpStats || []
              })
            }
            .width('100%')
            .height(300)
            .padding(24)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .border({ width: 1, color: this.themeBorderColor })
            .layoutWeight(1)
            .margin({ right: 8 })

            // 访客类型统计
            Column() {
              Text('访客类型')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.textColor)
                .margin({ bottom: 16 })

              UvTypeStatsList({
                uvTypeStats: this.statsData?.uvTypeStats || []
              })
            }
            .width('100%')
            .height(300)
            .padding(24)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .border({ width: 1, color: this.themeBorderColor })
            .layoutWeight(1)
            .margin({ left: 8 })
          }
          .width('100%')
          .margin({ bottom: 16 })

          // 第三行：网络类型和设备类型
          Row() {
            // 网络类型统计
            Column() {
              Text('网络类型')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.textColor)
                .margin({ bottom: 16 })

              NetworkStatsList({
                networkStats: this.statsData?.networkStats || []
              })
            }
            .width('100%')
            .height(300)
            .padding(24)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .border({ width: 1, color: this.themeBorderColor })
            .layoutWeight(1)
            .margin({ right: 8 })

            // 设备类型统计
            Column() {
              Text('设备类型')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.textColor)
                .margin({ bottom: 16 })

              DeviceStatsList({
                deviceStats: this.statsData?.deviceStats || []
              })
            }
            .width('100%')
            .height(300)
            .padding(24)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .border({ width: 1, color: this.themeBorderColor })
            .layoutWeight(1)
            .margin({ left: 8 })
          }
          .width('100%')
        }
        .width('100%')
        .padding(24)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .scrollBarColor(Color.Gray)
      .scrollBarWidth(4)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F3F5')
    .padding({ top: 10, bottom: 24 })
  }
}
