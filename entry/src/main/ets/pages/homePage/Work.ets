import { ShortLinkBaseStatsRespDTO, ShortLinkStatsAccessDailyRespDTO } from '../../model/UserInterface';
import { HttpUtils } from '../../JhCommon/http/HttpUtils';
import { APIs } from '../../JhCommon/http/APIs';
import { JhProgressHUD } from '../../JhCommon/components/JhProgressHUD';
import { DailyChart } from '../ShortLinkPage/statistics/DailyChart';
import { ShortLinkStatsData, DailyStats } from '../../model/UserInterface';

@Component
export struct Workbench {
  // 主题色常量
  readonly themeColor: string = '#1890FF';
  readonly cardBgColor: string = '#FFFFFF';
  readonly textColor: string = '#000000';
  readonly textColorSecondary: string = 'rgba(0, 0, 0, 0.65)';
  readonly cardColors: string[] = [
    '#E6F7FF', // 浅蓝色
    '#FFF1F0', // 浅红色
    '#E6FFFB', // 浅青色
    '#FCF4E8', // 浅黄色
    '#FFF7E6', // 浅橙色
    '#F6FFED', // 浅绿色
    '#F9F0FF', // 浅紫色
    '#FFF0F6'// 浅粉色
  ];
  readonly cardBorderColors: string[] = [
    '#91D5FF', // 蓝色
    '#FFA39E', // 红色
    '#5CDBD3', // 青色
    '#F0CD94', // 黄色
    '#FFD591', // 橙色
    '#B7EB8F', // 绿色
    '#D3ADF7', // 紫色
    '#FF85C0'// 粉色
  ];
  // 统计卡片数据
  @State statsData: ShortLinkBaseStatsRespDTO = {
    onlineUser: 0,
    onlineManager: 0,
    todayNewUser: 0,
    yesterdayNewUser: 0,
    todayPv: 0,
    todayUv: 0,
    yesterdayPv: 0,
    yesterdayUv: 0,
    daily: []
  };
  
  // 图表更新计数器
  @State chartUpdateCounter: number = 0;
  // 日期范围
  @State startDate: string = '';
  @State endDate: string = '';

  // 初始化
  aboutToAppear() {
    // 初始化 UI 上下文
    let uiContext: UIContext = this.getUIContext() as UIContext;
    JhProgressHUD.initUIConfig(uiContext);

    // 设置默认日期范围（近7天）
    this.setDefaultDateRange();
    
    // 获取基础统计信息
    this.fetchBaseStatsInfo();
  }
  
  // 设置默认日期范围（近7天）
  private setDefaultDateRange() {
    const today = new Date();
    const sevenDaysAgo = new Date(today);
    sevenDaysAgo.setDate(today.getDate() - 6); // 近7天，包括今天
    
    // 格式化日期为YYYY-MM-DD
    this.endDate = this.formatDate(today);
    this.startDate = this.formatDate(sevenDaysAgo);
    
    console.info(`日期范围已设置：${this.startDate} 至 ${this.endDate}`);
  }
  
  // 格式化日期为YYYY-MM-DD格式
  private formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  // 获取基础统计信息
  private async fetchBaseStatsInfo() {
    try {
      JhProgressHUD.showLoading();
      const res = await HttpUtils.get(APIs.getBaseStatsInfo, {});
      if (res.code === '0') {
        console.info('API返回数据:', res.data); // 添加调试日志
        // 确保所有字段都有值，即使API返回中不存在该字段
        this.statsData = {
          onlineUser: res.data?.onlineUser || 0,
          onlineManager: res.data?.onlineManager || 0,
          todayNewUser: res.data?.todayNewUser || 0,
          yesterdayNewUser: res.data?.yesterdayNewUser || 0,
          todayPv: res.data?.todayPv || 0,
          todayUv: res.data?.todayUv || 0,
          yesterdayPv: res.data?.yesterdayPv || 0,
          yesterdayUv: res.data?.yesterdayUv || 0,
          daily: res.data?.daily || []
        };
        console.info('处理后的统计数据:', this.statsData); // 添加调试日志
        
        // 增加计数器，触发图表更新
        this.chartUpdateCounter++;
        
        JhProgressHUD.hide();
      } else {
        JhProgressHUD.showError('获取统计数据失败');
      }
    } catch (error) {
      console.error('获取统计数据失败:', error);
      JhProgressHUD.showError('获取统计数据失败');
    }
  }

  build() {
    Scroll() {
      Column() {
        // 标题
        Text('工作台')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.textColor)
          .margin({ bottom: 16 })
          .alignSelf(ItemAlign.Start)

        // 所有卡片
        Row({ space: 16 }) {
          // 第一列 - 两个卡片
          Column({ space: 16 }) {
            // 在线用户人数卡片
            Column() {
              Text('在线用户')
                .fontSize(14)
                .fontColor(this.textColor)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 8 })

              Text(this.statsData.onlineUser?.toString() || '0')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.textColor)

              Text('活跃用户数')
                .fontSize(12)
                .fontColor(this.textColorSecondary)
                .margin({ top: 8 })
            }
            .width('100%')
            .height(120)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .padding(12)
            .backgroundColor(this.cardColors[0])
            .borderRadius(8)
            .border({ width: 1, color: this.cardBorderColors[0] })

            // 今日访问人次卡片
            Column() {
              Text('今日访问人次')
                .fontSize(14)
                .fontColor(this.textColor)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 8 })

              Text(this.statsData.todayPv?.toString() || '0')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.textColor)

              Text('浏览量（PV）')
                .fontSize(12)
                .fontColor(this.textColorSecondary)
                .margin({ top: 8 })
            }
            .width('100%')
            .height(120)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .padding(12)
            .backgroundColor(this.cardColors[4])
            .borderRadius(8)
            .border({ width: 1, color: this.cardBorderColors[4] })
          }
          .layoutWeight(1)

          // 第二列 - 两个卡片
          Column({ space: 16 }) {
            // 在线管理员人数卡片
            Column() {
              Text('在线管理员')
                .fontSize(14)
                .fontColor(this.textColor)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 8 })

              Text(this.statsData.onlineManager?.toString() || '0')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.textColor)

              Text('活跃管理员数')
                .fontSize(12)
                .fontColor(this.textColorSecondary)
                .margin({ top: 8 })
            }
            .width('100%')
            .height(120)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .padding(12)
            .backgroundColor(this.cardColors[1])
            .borderRadius(8)
            .border({ width: 1, color: this.cardBorderColors[1] })

            // 今日访问人数卡片
            Column() {
              Text('今日访问人数')
                .fontSize(14)
                .fontColor(this.textColor)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 8 })

              Text(this.statsData.todayUv?.toString() || '0')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.textColor)

              Text('独立访客（UV）')
                .fontSize(12)
                .fontColor(this.textColorSecondary)
                .margin({ top: 8 })
            }
            .width('100%')
            .height(120)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .padding(12)
            .backgroundColor(this.cardColors[5])
            .borderRadius(8)
            .border({ width: 1, color: this.cardBorderColors[5] })
          }
          .layoutWeight(1)

          // 第三列 - 两个卡片
          Column({ space: 16 }) {
            // 今日新增用户卡片
            Column() {
              Text('今日新增用户')
                .fontSize(14)
                .fontColor(this.textColor)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 8 })

              Text(this.statsData.todayNewUser?.toString() || '0')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.textColor)

              Text('新注册用户')
                .fontSize(12)
                .fontColor(this.textColorSecondary)
                .margin({ top: 8 })
            }
            .width('100%')
            .height(120)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .padding(12)
            .backgroundColor(this.cardColors[2])
            .borderRadius(8)
            .border({ width: 1, color: this.cardBorderColors[2] })

            // 昨日访问人次卡片
            Column() {
              Text('昨日访问人次')
                .fontSize(14)
                .fontColor(this.textColor)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 8 })

              Text(this.statsData.yesterdayPv?.toString() || '0')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.textColor)

              Text('浏览量（PV）')
                .fontSize(12)
                .fontColor(this.textColorSecondary)
                .margin({ top: 8 })
            }
            .width('100%')
            .height(120)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .padding(12)
            .backgroundColor(this.cardColors[6])
            .borderRadius(8)
            .border({ width: 1, color: this.cardBorderColors[6] })
          }
          .layoutWeight(1)

          // 第四列 - 两个卡片
          Column({ space: 16 }) {
            // 昨日新增用户卡片
            Column() {
              Text('昨日新增用户')
                .fontSize(14)
                .fontColor(this.textColor)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 8 })

              Text(this.statsData.yesterdayNewUser?.toString() || '0')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.textColor)

              Text('新注册用户')
                .fontSize(12)
                .fontColor(this.textColorSecondary)
                .margin({ top: 8 })
            }
            .width('100%')
            .height(120)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .padding(12)
            .backgroundColor(this.cardColors[3])
            .borderRadius(8)
            .border({ width: 1, color: this.cardBorderColors[3] })

            // 昨日访问人数卡片
            Column() {
              Text('昨日访问人数')
                .fontSize(14)
                .fontColor(this.textColor)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 8 })

              Text(this.statsData.yesterdayUv?.toString() || '0')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.textColor)

              Text('独立访客（UV）')
                .fontSize(12)
                .fontColor(this.textColorSecondary)
                .margin({ top: 8 })
            }
            .width('100%')
            .height(120)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .padding(12)
            .backgroundColor(this.cardColors[7])
            .borderRadius(8)
            .border({ width: 1, color: this.cardBorderColors[7] })
          }
          .layoutWeight(1)
        }
        .width('100%')
        .margin({ bottom: 24 })
        
        // 近七天访问记录图表
        Column() {
          // 图表标题
          Text('近七天访问记录')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.textColor)
            .margin({ bottom: 16 })
            .alignSelf(ItemAlign.Start)
          
          // 图表容器，添加边框和背景
          Column() {
            // 使用DailyChart组件
            DailyChart({
              statsData: this.convertToDailyStatsData(),
              startDate: this.startDate,
              endDate: this.endDate,
              updateCounter: this.chartUpdateCounter
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .border({ width: 1, color: '#E5E6EB' })
        }
        .width('100%')
        .margin({ bottom: 24 })
      }
      .width('100%')
      .padding(24)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Auto)
  }
  
  // 将API返回的数据转换为DailyChart所需的格式
  private convertToDailyStatsData(): ShortLinkStatsData {
    // 检查是否存在daily数据
    if (!this.statsData.daily || this.statsData.daily.length === 0) {
      console.info('没有daily数据，返回空数据');
      return new ShortLinkStatsData();
    }
    
    // 计算总计
    let totalPv = 0;
    let totalUv = 0;
    let totalUip = 0;
    
    this.statsData.daily.forEach(item => {
      totalPv += item.pv || 0;
      totalUv += item.uv || 0;
      totalUip += item.uip || 0;
    });
    
    // 创建结果对象
    const result = new ShortLinkStatsData();
    result.pv = totalPv;
    result.uv = totalUv;
    result.uip = totalUip;
    
    // 转换daily数据
    result.daily = this.statsData.daily.map(item => {
      const dailyStats = new DailyStats();
      dailyStats.date = item.date;
      dailyStats.pv = item.pv || 0;
      dailyStats.uv = item.uv || 0;
      dailyStats.uip = item.uip || 0;
      return dailyStats;
    });
    
    return result;
  }

  // 获取当前时间
  private getCurrentTime(): string {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const seconds = String(now.getSeconds()).padStart(2, '0');

    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
  }
}
