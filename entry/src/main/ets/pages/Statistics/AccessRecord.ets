import { JhProgressHUD } from '../../JhCommon/components/JhProgressHUD';
import { APIs } from '../../JhCommon/http/APIs';
import { HttpUtils } from '../../JhCommon/http/HttpUtils';
import { JhAESPreferencesUtils } from '../../JhCommon/utils/JhPreferencesUtils';
import { AccessRecord as AccessRecordItem, ShortLink, ShortLinkStatsData } from '../../model/ShortLinkInterface';
import router from '@ohos.router';

interface SelectOption {
  value: string;
  text: string;
}

// 添加图标映射定义
class IconMap {
  // 操作系统图标映射
  static readonly OS_ICONS: Record<string, Resource> = {
    'windows': $r('app.media.windows'),
    'linux': $r('app.media.linux'),
    'mac': $r('app.media.mac')
  };
  // 浏览器图标映射
  static readonly BROWSER_ICONS: Record<string, Resource> = {
    'chrome': $r('app.media.Chrome'),
    'edge': $r('app.media.Edge'),
    'ie': $r('app.media.IE'),
    'firefox': $r('app.media.firefox')
  };
  // 网络类型图标映射
  static readonly NETWORK_ICONS: Record<string, Resource> = {
    'mobile': $r('app.media.Mobile'),
    'wifi': $r('app.media.WIFI')
  };
  // 设备类型图标映射
  static readonly DEVICE_ICONS: Record<string, Resource> = {
    'pc': $r('app.media.computer'),
    'mobile': $r('app.media.Phone')
  };
  static readonly OTHER: Record<string, Resource> = {
    'unknown': $r("app.media.unknown"),
    'search': $r("app.media.select"),
  };

  // 获取操作系统图标
  static getOsIcon(os: string): Resource | null {
    if (!os) {
      return null;
    }
    const osLower = os.toLowerCase();
    if (osLower.includes('windows')) {
      return IconMap.OS_ICONS.windows;
    } else if (osLower.includes('linux')) {
      return IconMap.OS_ICONS.linux;
    } else if (osLower.includes('mac os')) {
      return IconMap.OS_ICONS.mac;
    } else {
      return IconMap.OTHER.unknown;
    }
  }

  // 获取浏览器图标
  static getBrowserIcon(browser: string): Resource | null {
    if (!browser) {
      return null;
    }
    const browserLower = browser.toLowerCase();
    if (browserLower.includes('google chrome')) {
      return IconMap.BROWSER_ICONS.chrome;
    } else if (browserLower.includes('microsoft edge')) {
      return IconMap.BROWSER_ICONS.edge;
    } else if (browserLower.includes('ie')) {
      return IconMap.BROWSER_ICONS.ie;
    } else if (browserLower.includes('firefox')) {
      return IconMap.BROWSER_ICONS.firefox;
    } else {
      return IconMap.OTHER.unknown;
    }
  }

  // 获取网络类型图标
  static getNetworkIcon(network: string): Resource | null {
    if (!network) {
      return null;
    }
    const networkLower = network.toLowerCase();
    if (networkLower.includes('wifi')) {
      return IconMap.NETWORK_ICONS.wifi;
    } else if (networkLower.includes('mobile') || networkLower.includes('cellular')) {
      return IconMap.NETWORK_ICONS.mobile;
    } else {
      return IconMap.OTHER.unknown;
    }
  }

  // 获取设备类型图标
  static getDeviceIcon(device: string): Resource | null {
    if (!device) {
      return null;
    }
    const deviceLower = device.toLowerCase();
    if (deviceLower.includes('pc')) {
      return IconMap.DEVICE_ICONS.computer;
    } else if (deviceLower.includes('mobile') || deviceLower.includes('phone')) {
      return IconMap.DEVICE_ICONS.mobile;
    } else {
      return IconMap.OTHER.unknown;
    }
  }
}

@Component
export struct AccessRecord {
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
  @State shortLink: ShortLink | null = null;
  
  // 访问记录相关状态
  @State accessRecords: Array<AccessRecordItem> = [];
  @State totalPages: number = 1;
  @State currentPage: number = 1;
  @State pageSize: number = 10; // 每页显示10条记录
  @State inputPage: string = ''; // 用于存储输入的页码
  // 添加页码范围状态，用于存储计算结果
  @State pageRangeStart: number = 1;
  @State pageRangeEnd: number = 1;

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
      // 获取访问记录数据
      this.fetchAccessRecords();
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
          // 获取访问记录数据
          this.fetchAccessRecords();
        }
      } else {
        JhProgressHUD.showError('获取数据失败');
      }
    } catch (error) {
      console.error('获取数据失败:', error);
      JhProgressHUD.showError('获取数据失败');
    }
  }

  // 获取访问记录数据
  private async fetchAccessRecords() {
    try {
      console.info(`[访问记录] 开始获取数据，API: ${APIs.groupShortLinkStatsRecord}`);

      // 检查是否选择了用户
      if (!this.selectedUser) {
        JhProgressHUD.showError('请先选择用户/公司');
        return;
      }

      // 定义请求参数接口
      interface AccessRecordRequestParams {
        startDate: string;
        endDate: string;
        size: number;
        current: number;
        username: string;
      }

      // 构建请求参数
      const params: AccessRecordRequestParams = {
        startDate: this.formatDateTime(new Date(this.startDate), true),
        endDate: this.formatDateTime(new Date(this.endDate), false),
        size: this.pageSize, // 每页显示条数
        current: this.currentPage, // 当前页码
        username: this.selectedUser  // 使用下拉框选择的用户名
      };

      console.info(`[访问记录] 请求参数: ${JSON.stringify(params)}`);

      const res = await HttpUtils.post(APIs.groupShortLinkStatsRecord, params);
      console.info(`[访问记录] 响应结果: ${JSON.stringify(res)}`);

      if (res.code === '0') {
        this.accessRecords = res.data.records;
        this.totalPages = Math.ceil(res.data.total / this.pageSize);
        // 计算页码范围
        this.calculatePageRange();
        // 隐藏加载提示
        JhProgressHUD.hide();
      } else {
        // 显示错误提示
        console.error(`[访问记录] 获取数据失败: ${res.message}`);
        JhProgressHUD.showError('获取数据失败');
      }
    } catch (error) {
      console.error('获取访问记录失败:', error);
      JhProgressHUD.showError('获取访问记录失败');
    }
  }

  // 计算页码范围
  private calculatePageRange(): Array<number> {
    // 计算要显示的页码范围
    this.pageRangeStart = Math.max(1, this.currentPage - 2);
    this.pageRangeEnd = Math.min(this.totalPages, this.pageRangeStart + 4);

    // 调整pageRangeStart，确保显示5个页码（如果总页数足够）
    if (this.pageRangeEnd - this.pageRangeStart < 4 && this.totalPages >= 5) {
      this.pageRangeStart = Math.max(1, this.pageRangeEnd - 4);
    }

    // 返回页码数组
    const pageNumbers: Array<number> = [];
    for (let i = this.pageRangeStart; i <= this.pageRangeEnd; i++) {
      pageNumbers.push(i);
    }
    return pageNumbers;
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

  // 格式化访问记录中的地区
  private formatLocale(item: AccessRecordItem): string {
    if (item.locale) {
      const parts = item.locale.split(',');
      if (parts.length > 1) {
        return parts[0].trim() + ', ' + parts[1].trim();
      }
    }
    return item.locale || '-';
  }

  build() {
    Column() {
      // 标题
      Text('访问记录')
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
            this.currentPage = 1; // 重置为第一页
            this.fetchAccessRecords();
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
            // 重置当前页为第一页
            this.currentPage = 1;
            // 查询数据
            this.fetchAccessRecords();
          })
        }
      }
      .width('100%')
      .margin({ bottom: 12 })
      .justifyContent(FlexAlign.Start)

      // 访问记录表格
      Column() {
        // 表头
        Row() {
          Text('访问时间')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.textColor)
            .width('22%')
            .textAlign(TextAlign.Center)

          Text('访问IP')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.textColor)
            .width('18%')
            .textAlign(TextAlign.Center)

          Text('访客地区')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.textColor)
            .width('32%')
            .textAlign(TextAlign.Center)

          Text('设备信息')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.textColor)
            .width('18%')
            .textAlign(TextAlign.Center)

          Text('访客类型')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.textColor)
            .width('10%')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .zIndex(2)

        // 表格内容 - 使用Scroll使内容可滚动
        Scroll() {
          Column() {
            List() {
              ForEach(this.accessRecords, (item: AccessRecordItem) => {
                ListItem() {
                  Row() {
                    Text(item.createTime || '-')
                      .fontSize(14)
                      .fontColor(this.textColor)
                      .width('22%')
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(1)
                      .textAlign(TextAlign.Center)

                    Text(item.ip || '-')
                      .fontSize(14)
                      .fontColor(this.textColor)
                      .width('18%')
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(1)
                      .textAlign(TextAlign.Center)

                    Text(this.formatLocale(item))
                      .fontSize(14)
                      .fontColor(this.textColor)
                      .width('32%')
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(1)
                      .textAlign(TextAlign.Center)

                    Row({ space: 4 }) {
                      if (item.os) {
                        Column() {
                          Image(IconMap.getOsIcon(item.os) || $r('app.media.windows'))
                            .width(20)
                            .height(20)
                            .objectFit(ImageFit.Contain)
                        }
                      }

                      if (item.browser) {
                        Column() {
                          Image(IconMap.getBrowserIcon(item.browser) || $r('app.media.Chrome'))
                            .width(20)
                            .height(20)
                            .objectFit(ImageFit.Contain)
                        }
                      }

                      if (item.network) {
                        Column() {
                          Image(IconMap.getNetworkIcon(item.network) || $r('app.media.WIFI'))
                            .width(20)
                            .height(20)
                            .objectFit(ImageFit.Contain)
                        }
                      }

                      if (item.device) {
                        Column() {
                          Image(IconMap.getDeviceIcon(item.device) || $r('app.media.computer'))
                            .width(20)
                            .height(20)
                            .objectFit(ImageFit.Contain)
                        }
                      }
                    }
                    .width('18%')
                    .justifyContent(FlexAlign.Center)
                    .onClick(() => {
                    })

                    Text(item.user === 'newUser' ? '新访客' : '老访客')
                      .fontSize(14)
                      .fontColor(this.textColor)
                      .width('10%')
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(1)
                      .textAlign(TextAlign.Center)
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor(Color.White)
                }
              })
            }
            .width('100%')
            .layoutWeight(1)

            // 无数据提示
            if (this.accessRecords.length === 0) {
              Column() {
                Text('暂无访问记录')
                  .fontSize(16)
                  .fontColor(this.textColorSecondary)
              }
              .width('100%')
              .height(300)
              .backgroundColor(Color.White)
              .justifyContent(FlexAlign.Center)
            }

            // 分页控制
            Row() {
              // 所有分页元素放在同一个Row中
              Row({ space: 8 }) {
                // 上一页按钮
                Row() {
                  Text('<')
                    .fontSize(14)
                    .fontColor(this.currentPage > 1 ? this.themeColor : this.textColorSecondary)
                }
                .padding(8)
                .backgroundColor(this.themeColorLight)
                .borderRadius(4)
                .enabled(this.currentPage > 1)
                .onClick(() => {
                  if (this.currentPage > 1) {
                    this.currentPage--;
                    this.fetchAccessRecords();
                  }
                })

                // 页码按钮
                ForEach(this.calculatePageRange(), (page: number) => {
                  Row() {
                    Text(`${page}`)
                      .fontSize(14)
                      .fontColor(page === this.currentPage ? Color.White : this.themeColor)
                  }
                  .padding(8)
                  .backgroundColor(page === this.currentPage ? this.themeColor : this.themeColorLight)
                  .borderRadius(4)
                  .onClick(() => {
                    if (page !== this.currentPage) {
                      this.currentPage = page;
                      this.fetchAccessRecords();
                    }
                  })
                })

                // 下一页按钮
                Row() {
                  Text('>')
                    .fontSize(14)
                    .fontColor(this.currentPage < this.totalPages ? this.themeColor : this.textColorSecondary)
                }
                .padding(8)
                .backgroundColor(this.themeColorLight)
                .borderRadius(4)
                .enabled(this.currentPage < this.totalPages)
                .onClick(() => {
                  if (this.currentPage < this.totalPages) {
                    this.currentPage++;
                    this.fetchAccessRecords();
                  }
                })

                // 页数信息
                Text(`${this.currentPage}/${this.totalPages}页`)
                  .fontSize(14)
                  .fontColor(this.textColor)
                  .margin({ left: 8, right: 8 })

                // 跳转页码输入
                Text('跳至')
                  .fontSize(14)
                  .fontColor(this.textColor)

                TextInput({ text: this.inputPage })
                  .width(40)
                  .height(32)
                  .backgroundColor(this.themeColorLight)
                  .borderRadius(4)
                  .type(InputType.Number)
                  .onChange((value: string) => {
                    this.inputPage = value;
                  })

                Text('页')
                  .fontSize(14)
                  .fontColor(this.textColor)

                Button('确定')
                  .fontSize(14)
                  .fontColor(Color.White)
                  .backgroundColor(this.themeColor)
                  .borderRadius(4)
                  .height(32)
                  .onClick(() => {
                    let pageNum = 0;
                    try {
                      pageNum = parseInt(this.inputPage.trim());
                    } catch (e) {
                      pageNum = 0;
                    }

                    if (pageNum >= 1 && pageNum <= this.totalPages) {
                      this.currentPage = pageNum;
                      this.fetchAccessRecords();
                      this.inputPage = '';
                    } else {
                      JhProgressHUD.showText('请输入有效页码');
                    }
                  })
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding({
              left: 16,
              right: 16,
              top: 8,
              bottom: 12
            })
            .backgroundColor(Color.White)
            .zIndex(2)
          }
          .width('100%')
          .height('100%')
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Start)
        }
        .scrollBar(BarState.Auto)
        .scrollBarColor(Color.Gray)
        .scrollBarWidth(4)
        .edgeEffect(EdgeEffect.Spring)
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F3F5')
    .padding({ top: 20, left: 24, right: 24, bottom: 24 })
  }
}
