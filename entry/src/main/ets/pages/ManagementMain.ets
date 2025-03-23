import { ShortLinkStatsData, User, OverviewData, StatsMenuItem } from '../model/i';
import { Workbench } from './Home/work';
import { UserList } from './User/UserList';

@Entry
@Component
struct ManagementMain {
  // 主题色常量
  readonly themeColor: string = '#1890FF';
  readonly navBgColor: string = '#3E4346'; // 修改为更浅的灰色
  readonly navActiveColor: string = '#1890FF'; // 修改为主题色，作为选中背景色
  readonly contentBgColor: string = '#F0F2F5'; // 右侧内容区背景色
  readonly cardBgColor: string = '#FFFFFF'; // 卡片背景色
  readonly textColor: string = '#000000'; // 主要文字颜色
  readonly textColorSecondary: string = 'rgba(0, 0, 0, 0.65)'; // 次要文字颜色
  readonly navTextColor: string = '#FFFFFF'; // 导航文字颜色
  readonly navTextColorSecondary: string = 'rgba(255, 255, 255, 0.65)'; // 导航次要文字颜色
  readonly borderColorValue: string = '#E5E6EB';
  readonly successColor: string = '#52C41A';
  readonly dangerColor: string = '#FF4D4F';
  // 导航状态
  @State currentNav: string = 'dashboard'; // 当前选中的主菜单
  @State currentSubNav: string = 'workbench'; // 当前选中的子菜单
  @State isCollapsed: boolean = false; // 控制导航栏是否折叠
  @State expandedMenus: Set<string> = new Set(['dashboard']); // 展开的菜单集合
  @State hoveredMenu: string = ''; // 当前悬停的菜单项
  @State hoveredSubMenu: string = ''; // 当前悬停的子菜单项
  // 数据状态
  @State userList: Array<User> = [];
  @State currentPage: number = 1;
  @State pageSize: number = 10;
  @State totalPages: number = 1;
  @State statsData: ShortLinkStatsData | null = null;
  @State startDate: string = '';
  @State endDate: string = '';
  @State selectedStartDate: Date = new Date(new Date().setDate(new Date().getDate() - 7));
  @State selectedEndDate: Date = new Date();
  @State searchKeyword: string = '';
  // 统计卡片数据
  @State overviewData: OverviewData[] = [
    {
      title: '访问量',
      value: '2,000',
      total: '120,000',
      icon: '/common/images/ic_public_add.svg'
    },
    {
      title: '成交额',
      value: '20,000',
      total: '500,000',
      icon: '/common/images/ic_public_add.svg'
    },
    {
      title: '下载数',
      value: '8,000',
      total: '120,000',
      icon: '/common/images/ic_public_add.svg'
    },
    {
      title: '成交数',
      value: '5,000',
      total: '50,000',
      icon: '/common/images/ic_public_add.svg'
    }
  ]
  // 数据统计子菜单项
  private statsSubMenus: StatsMenuItem[] = [
    { key: 'visit', title: '访问统计' },
    { key: 'region', title: '地区分布' },
    { key: 'hourly', title: '24小时分布' },
    { key: 'ip', title: 'IP分布' },
    { key: 'weekly', title: '一周分布' },
    { key: 'os', title: '操作系统' },
    { key: 'browser', title: '访问浏览器' },
    { key: 'visitor', title: '访客类型' },
    { key: 'network', title: '访问网络' },
    { key: 'device', title: '访问设备' }
  ]

  aboutToAppear() {
    // 初始化日期范围
    const end = new Date();
    const start = new Date();
    start.setDate(start.getDate() - 7);
    this.startDate = this.formatDate(start);
    this.endDate = this.formatDate(end);

    // 获取初始数据
    this.fetchUserList();
  }

  // 格式化日期
  private formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  // 获取用户列表
  private async fetchUserList() {
    // 实现获取用户列表的逻辑
  }

  // 获取统计数据
  private async fetchStatsData() {
    try {
      // 这里应该添加实际的API调用逻辑
      console.info(`搜索统计数据，日期范围: ${this.startDate} 至 ${this.endDate}`);

      // 模拟数据获取成功
      this.statsData = {
        pv: 8765,
        uv: 2345,
        uip: 1987,
        daily: []
      };

    } catch (error) {
      console.error('获取统计数据失败:', error);
      // 可以添加错误提示
    }
  }

  build() {
    Row() {
      // 左侧导航栏
      Column() {
        // Logo区域
        Row() {
          if (!this.isCollapsed) {
            Row() {
              Text('短链接后台管理')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.navTextColor)

              // 展开状态下，收起按钮在右侧
              Image($r('app.media.left'))
                .width(20)
                .height(20)
                .fillColor(this.navTextColorSecondary)
                .onClick(() => {
                  this.isCollapsed = !this.isCollapsed;
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          } else {
            // 收起状态下，收起按钮与下方图标左对齐
            Image($r('app.media.right'))
              .width(20)
              .height(20)
              .fillColor(this.navTextColorSecondary)
              .onClick(() => {
                this.isCollapsed = !this.isCollapsed;
              })
          }
        }
        .width('100%')
        .height(64)
        .padding({ left: 24, right: 24, top: 40 })
        .alignItems(VerticalAlign.Center)

        // 添加间隔
        Blank().height(30)

        // 导航菜单
        Scroll() {
        Column() {
          // 仪表盘
          Column() {
            Row() {
              Row() {
                  Image($r('app.media.main'))
                  .width(20)
                  .height(20)
                  .margin({ right: 12 })
                    .fillColor(this.navTextColorSecondary)
                if (!this.isCollapsed) {
                  Text('首页')
                    .fontSize(14)
                      .fontColor(this.navTextColorSecondary)
                }
              }

              if (!this.isCollapsed) {
                Image(this.expandedMenus.has('dashboard') ? $r('app.media.down') : $r('app.media.right'))
                  .width(16)
                  .height(16)
                  .fillColor(this.navTextColorSecondary)
              }
            }
            .width('100%')
            .height(48)
            .padding({ left: 24, right: 24 })
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(() => {
              if (this.expandedMenus.has('dashboard')) {
                this.expandedMenus.delete('dashboard');
              } else {
                this.expandedMenus.add('dashboard');
              }
            })
              .onHover((isHover: boolean) => {
                this.hoveredMenu = isHover ? 'dashboard' : '';
              })
              .backgroundColor(this.hoveredMenu === 'dashboard' ? 'rgba(255, 255, 255, 0.1)' : 'transparent')
              .borderRadius(4)

            // 首页子菜单
            if (!this.isCollapsed && this.expandedMenus.has('dashboard')) {
              Column() {
                Row() {
                  Text('工作台')
                    .fontSize(14)
                    .fontColor(this.currentSubNav === 'workbench' ? Color.White : this.navTextColorSecondary)
                }
                .width('100%')
                .height(40)
                  .padding({ left: 71 })
                  .backgroundColor(this.currentSubNav === 'workbench' ? this.navActiveColor :
                    this.hoveredSubMenu === 'workbench' ? 'rgba(255, 255, 255, 0.1)' : 'transparent')
                  .borderRadius(4)
                .onClick(() => {
                  this.currentSubNav = 'workbench';
                    this.currentNav = 'dashboard';
                  })
                  .onHover((isHover: boolean) => {
                    this.hoveredSubMenu = isHover ? 'workbench' : '';
                })
              }
              .width('100%')
              .animation({
                duration: 200,
                curve: Curve.EaseInOut
              })
            }
          }

          // 用户管理
          Column() {
            Row() {
              Row() {
                Image($r('app.media.user'))
                  .width(20)
                  .height(20)
                  .margin({ right: 12 })
                    .fillColor(this.navTextColorSecondary)
                if (!this.isCollapsed) {
                  Text('用户管理')
                    .fontSize(14)
                      .fontColor(this.navTextColorSecondary)
                }
              }

              if (!this.isCollapsed) {
                Image(this.expandedMenus.has('user') ? $r('app.media.down') : $r('app.media.right'))
                  .width(16)
                  .height(16)
                  .fillColor(this.navTextColorSecondary)
              }
            }
            .width('100%')
            .height(48)
            .padding({ left: 24, right: 24 })
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(() => {
              if (this.expandedMenus.has('user')) {
                this.expandedMenus.delete('user');
              } else {
                this.expandedMenus.add('user');
              }
            })
              .onHover((isHover: boolean) => {
                this.hoveredMenu = isHover ? 'user' : '';
              })
              .backgroundColor(this.hoveredMenu === 'user' ? 'rgba(255, 255, 255, 0.1)' : 'transparent')
              .borderRadius(4)

            // 用户管理子菜单
            if (!this.isCollapsed && this.expandedMenus.has('user')) {
              Column() {
                Row() {
                  Text('用户列表')
                    .fontSize(14)
                    .fontColor(this.currentSubNav === 'userList' ? Color.White : this.navTextColorSecondary)
                }
                .width('100%')
                .height(40)
                  .padding({ left: 71 })
                  .backgroundColor(this.currentSubNav === 'userList' ? this.navActiveColor :
                    this.hoveredSubMenu === 'userList' ? 'rgba(255, 255, 255, 0.1)' : 'transparent')
                  .borderRadius(4)
                .onClick(() => {
                  this.currentSubNav = 'userList';
                    this.currentNav = 'user';
                  })
                  .onHover((isHover: boolean) => {
                    this.hoveredSubMenu = isHover ? 'userList' : '';
                })

                Row() {
                  Text('管理员列表')
                    .fontSize(14)
                    .fontColor(this.currentSubNav === 'roleManage' ? Color.White : this.navTextColorSecondary)
                }
                .width('100%')
                .height(40)
                  .padding({ left: 71 })
                  .backgroundColor(this.currentSubNav === 'roleManage' ? this.navActiveColor :
                    this.hoveredSubMenu === 'roleManage' ? 'rgba(255, 255, 255, 0.1)' : 'transparent')
                  .borderRadius(4)
                .onClick(() => {
                  this.currentSubNav = 'roleManage';
                    this.currentNav = 'user';
                  })
                  .onHover((isHover: boolean) => {
                    this.hoveredSubMenu = isHover ? 'roleManage' : '';
                })
              }
              .width('100%')
              .animation({
                duration: 200,
                curve: Curve.EaseInOut
              })
            }
          }

            // 短链接管理
            Column() {
              Row() {
                Row() {
                  Image($r('app.media.link'))
                    .width(20)
                    .height(20)
                    .margin({ right: 12 })
                    .fillColor(this.navTextColorSecondary)
                  if (!this.isCollapsed) {
                    Text('短链接管理')
                      .fontSize(14)
                      .fontColor(this.navTextColorSecondary)
                  }
                }

                if (!this.isCollapsed) {
                  Image(this.expandedMenus.has('shortlink') ? $r('app.media.down') : $r('app.media.right'))
                    .width(16)
                    .height(16)
                    .fillColor(this.navTextColorSecondary)
                }
              }
              .width('100%')
              .height(48)
              .padding({ left: 24, right: 24 })
              .justifyContent(FlexAlign.SpaceBetween)
              .onClick(() => {
                if (this.expandedMenus.has('shortlink')) {
                  this.expandedMenus.delete('shortlink');
                } else {
                  this.expandedMenus.add('shortlink');
                }
              })
              .onHover((isHover: boolean) => {
                this.hoveredMenu = isHover ? 'shortlink' : '';
              })
              .backgroundColor(this.hoveredMenu === 'shortlink' ? 'rgba(255, 255, 255, 0.1)' : 'transparent')
              .borderRadius(4)
            }

            // 短链接管理子菜单
            if (!this.isCollapsed && this.expandedMenus.has('shortlink')) {
              Column() {
                Row() {
                  Text('短链接列表')
                    .fontSize(14)
                    .fontColor(this.currentSubNav === 'shortlinkList' ? Color.White : this.navTextColorSecondary)
                }
                .width('100%')
                .height(40)
                .padding({ left: 71 })
                .backgroundColor(this.currentSubNav === 'shortlinkList' ? this.navActiveColor :
                  this.hoveredSubMenu === 'shortlinkList' ? 'rgba(255, 255, 255, 0.1)' : 'transparent')
                .borderRadius(4)
                .onClick(() => {
                  this.currentSubNav = 'shortlinkList';
                  this.currentNav = 'shortlink';
                })
                .onHover((isHover: boolean) => {
                  this.hoveredSubMenu = isHover ? 'shortlinkList' : '';
                })
              }
              .width('100%')
              .animation({
                duration: 200,
                curve: Curve.EaseInOut
              })
            }

          // 数据统计
          Column() {
            Row() {
              Row() {
                  Image($r('app.media.statistics'))
                  .width(20)
                  .height(20)
                  .margin({ right: 12 })
                    .fillColor(this.navTextColorSecondary)
                if (!this.isCollapsed) {
                  Text('数据统计')
                    .fontSize(14)
                      .fontColor(this.navTextColorSecondary)
                }
              }

              if (!this.isCollapsed) {
                Image(this.expandedMenus.has('stats') ? $r('app.media.down') : $r('app.media.right'))
                  .width(16)
                  .height(16)
                  .fillColor(this.navTextColorSecondary)
              }
            }
            .width('100%')
            .height(48)
            .padding({ left: 24, right: 24 })
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(() => {
              if (this.expandedMenus.has('stats')) {
                this.expandedMenus.delete('stats');
              } else {
                this.expandedMenus.add('stats');
              }
            })
              .onHover((isHover: boolean) => {
                this.hoveredMenu = isHover ? 'stats' : '';
              })
              .backgroundColor(this.hoveredMenu === 'stats' ? 'rgba(255, 255, 255, 0.1)' : 'transparent')
              .borderRadius(4)

            // 数据统计子菜单
            if (!this.isCollapsed && this.expandedMenus.has('stats')) {
              Column() {
                ForEach(this.statsSubMenus, (item: StatsMenuItem) => {
                  Row() {
                    Text(item.title)
                      .fontSize(14)
                      .fontColor(this.currentSubNav === item.key ? Color.White : this.navTextColorSecondary)
                  }
                  .width('100%')
                  .height(40)
                    .padding({ left: 71 })
                    .backgroundColor(this.currentSubNav === item.key ? this.navActiveColor :
                      this.hoveredSubMenu === item.key ? 'rgba(255, 255, 255, 0.1)' : 'transparent')
                    .borderRadius(4)
                  .onClick(() => {
                    this.currentSubNav = item.key;
                    this.currentNav = 'stats';
                  })
                    .onHover((isHover: boolean) => {
                      this.hoveredSubMenu = isHover ? item.key : '';
                    })
                })
              }
              .width('100%')
              .animation({
                duration: 200,
                curve: Curve.EaseInOut
              })
            }
          }

            // 黑名单
            Column() {
        Row() {
                Row() {
                  Image($r('app.media.black'))
            .width(20)
            .height(20)
                    .margin({ right: 12 })
            .fillColor(this.navTextColorSecondary)
                  if (!this.isCollapsed) {
                    Text('黑名单')
                      .fontSize(14)
                      .fontColor(this.navTextColorSecondary)
                  }
                }

                if (!this.isCollapsed) {
                  Image(this.expandedMenus.has('whitelist') ? $r('app.media.down') : $r('app.media.right'))
                    .width(16)
                    .height(16)
                    .fillColor(this.navTextColorSecondary)
                }
        }
        .width('100%')
        .height(48)
        .padding({ left: 24, right: 24 })
              .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
                if (this.expandedMenus.has('whitelist')) {
                  this.expandedMenus.delete('whitelist');
                } else {
                  this.expandedMenus.add('whitelist');
                }
              })
              .onHover((isHover: boolean) => {
                this.hoveredMenu = isHover ? 'whitelist' : '';
              })
              .backgroundColor(this.hoveredMenu === 'whitelist' ? 'rgba(255, 255, 255, 0.1)' : 'transparent')
              .borderRadius(4)

              // 黑名单子菜单
              if (!this.isCollapsed && this.expandedMenus.has('whitelist')) {
                Column() {
                  Row() {
                    Text('黑名单列表')
                      .fontSize(14)
                      .fontColor(this.currentSubNav === 'whitelistList' ? Color.White : this.navTextColorSecondary)
                  }
                  .width('100%')
                  .height(40)
                  .padding({ left: 71 })
                  .backgroundColor(this.currentSubNav === 'whitelistList' ? this.navActiveColor :
                    this.hoveredSubMenu === 'whitelistList' ? 'rgba(255, 255, 255, 0.1)' : 'transparent')
                  .borderRadius(4)
                  .onClick(() => {
                    this.currentSubNav = 'whitelistList';
                    this.currentNav = 'whitelist';
                  })
                  .onHover((isHover: boolean) => {
                    this.hoveredSubMenu = isHover ? 'whitelistList' : '';
                  })
                }
                .width('100%')
                .animation({
                  duration: 200,
                  curve: Curve.EaseInOut
                })
              }
            }

            // 填充剩余空间，确保无空白
            Blank()
              .layoutWeight(1)
              .backgroundColor(this.navBgColor)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .height('100%')
        .scrollBarWidth(4)
        .scrollBarColor(Color.Gray)
        .scrollable(ScrollDirection.Vertical)
        .edgeEffect(EdgeEffect.Spring)
        .width('100%')
        .layoutWeight(1)
      }
      .width(this.isCollapsed ? 80 : 220)
      .height('100%')
      .backgroundColor(this.navBgColor)

      // 右侧内容区域
      Column() {
        // 顶部栏
        Row() {
          // 面包屑导航
          Row({ space: 8 }) {
            Text('短链接管理')
              .fontSize(14)
              .fontColor(this.textColorSecondary)
            Text('/')
              .fontSize(14)
              .fontColor(this.textColorSecondary)
            Text(this.currentSubNav === 'workbench' ? '工作台' :
              this.currentNav === 'user' && this.currentSubNav === 'userList' ? '用户列表' :
                this.currentNav === 'user' && this.currentSubNav === 'roleManage' ? '管理员列表' :
                  this.currentNav === 'shortlink' && this.currentSubNav === 'shortlinkList' ? '短链接列表' :
                    this.currentNav === 'stats' ? '数据统计' :
                      this.currentNav === 'whitelist' && this.currentSubNav === 'whitelistList' ? '白名单列表' : '')
              .fontSize(14)
              .fontColor(this.textColor)
          }
          .margin({ top: 40 })
          .height(80)

          // 右侧工具栏
          Row({ space: 16 }) {
            Image($r('app.media.user'))
              .width(20)
              .height(20)
              .fillColor(this.textColorSecondary)
            Image($r('app.media.user'))
              .width(20)
              .height(20)
              .fillColor(this.textColorSecondary)
            Image($r('app.media.user'))
              .width(32)
              .height(32)
              .borderRadius(16)
          }
        }
        .width('100%')
        .height(64)
        .padding({ left: 24, right: 24 })
        .backgroundColor(this.cardBgColor)
        .border({ width: { bottom: 1 }, color: this.borderColorValue })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)

        // 主要内容区域
        Scroll() {
          Column() {
            if (this.currentNav === 'dashboard') {
              Workbench()
            } else if (this.currentNav === 'user') {
              UserList()
            } else if (this.currentNav === 'shortlink') {
              // 短链接列表内容
              Column() {
                Text('短链接列表（待实现）')
                  .fontSize(18)
                        .fontWeight(FontWeight.Medium)
                  .margin({ top: 20 })
                    }
                    .width('100%')
              .padding(24)
            } else if (this.currentNav === 'stats') {
              // 数据统计内容
              Column() {
                // 日期选择和搜索按钮
                Row() {
                  Row() {
                    Text('日期范围：')
                      .fontSize(14)
                      .fontColor(this.textColor)

                    // 开始日期按钮
                    Button({ type: ButtonType.Capsule }) {
                      Text(this.startDate)
                        .fontSize(14)
                        .fontColor(this.textColor)
                    }
                    .backgroundColor(Color.White)
                    .border({ width: 1, color: this.borderColorValue })
                    .height(32)
                    .onClick(() => {
                      // 显示日期选择器
                    })

                    Text(' 至 ')
                      .fontSize(14)
                      .fontColor(this.textColor)

                    // 结束日期按钮
                    Button({ type: ButtonType.Capsule }) {
                      Text(this.endDate)
                        .fontSize(14)
                        .fontColor(this.textColor)
                    }
                    .backgroundColor(Color.White)
                    .border({ width: 1, color: this.borderColorValue })
                    .height(32)
                    .onClick(() => {
                      // 显示日期选择器
                    })
                  }

                  // 搜索框和按钮
                  Row() {
                    TextInput({ placeholder: '请输入关键词搜索', text: this.searchKeyword })
                      .width(200)
                      .height(32)
                      .backgroundColor(Color.White)
                      .borderRadius(2)
                      .border({ width: 1, color: this.borderColorValue })
                      .onChange((value: string) => {
                        this.searchKeyword = value;
                      })
                      .margin({ right: 8 })

                  // 搜索按钮
                  Button('搜索')
                    .height(32)
                    .backgroundColor(this.themeColor)
                    .fontColor(Color.White)
                      .borderRadius(2)
                    .onClick(() => {
                        this.fetchStatsData();
                    })
                  }
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .margin({ bottom: 24 })

                // 统计数据展示
                Grid() {
                  // 访问量统计
                  GridItem() {
                    Column() {
                      Row() {
                        Text('总访问量')
                          .fontSize(14)
                          .fontColor(this.textColorSecondary)
                        Image($r('app.media.user'))
                          .width(20)
                          .height(20)
                          .margin({ left: 8 })
                      }

                      Text(this.statsData?.pv?.toString() || '0')
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(this.textColor)
                        .margin({ top: 8 })

                      Text('较上周')
                        .fontSize(12)
                        .fontColor(this.textColorSecondary)
                        .margin({ top: 4 })
                    }
                    .width('100%')
                    .height(120)
                    .backgroundColor(Color.White)
                    .borderRadius(8)
                    .padding(16)
                    .justifyContent(FlexAlign.Center)
                  }

                  // 访客数统计
                  GridItem() {
                    Column() {
                      Row() {
                        Text('访客数')
                          .fontSize(14)
                          .fontColor(this.textColorSecondary)
                        Image($r('app.media.user'))
                          .width(20)
                          .height(20)
                          .margin({ left: 8 })
                      }

                      Text(this.statsData?.uv?.toString() || '0')
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(this.textColor)
                        .margin({ top: 8 })

                      Text('较上周')
                        .fontSize(12)
                        .fontColor(this.textColorSecondary)
                        .margin({ top: 4 })
                    }
                    .width('100%')
                    .height(120)
                    .backgroundColor(Color.White)
                    .borderRadius(8)
                    .padding(16)
                    .justifyContent(FlexAlign.Center)
                  }

                  // IP数统计
                  GridItem() {
                    Column() {
                      Row() {
                        Text('IP数')
                          .fontSize(14)
                          .fontColor(this.textColorSecondary)
                        Image($r('app.media.user'))
                          .width(20)
                          .height(20)
                          .margin({ left: 8 })
                      }

                      Text(this.statsData?.uip?.toString() || '0')
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(this.textColor)
                        .margin({ top: 8 })

                      Text('较上周')
                        .fontSize(12)
                        .fontColor(this.textColorSecondary)
                        .margin({ top: 4 })
                    }
                    .width('100%')
                    .height(120)
                    .backgroundColor(Color.White)
                    .borderRadius(8)
                    .padding(16)
                    .justifyContent(FlexAlign.Center)
                  }
                }
                .columnsTemplate('1fr 1fr 1fr')
                .columnsGap(16)
                .rowsGap(16)
                .width('100%')
                .margin({ bottom: 24 })

                // 图表区域
                Grid() {
                  // 访问趋势图
                  GridItem() {
                    Column() {
                      Text('访问趋势')
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.textColor)
                        .margin({ bottom: 16 })

                      // 模拟图表内容
                      Row() {
                        Column() {
                          Divider().height(1).color('#EEEEEE')
                          Text('暂无数据')
                            .fontSize(14)
                            .fontColor(this.textColorSecondary)
                            .margin({ top: 100 })
                          Divider().height(1).color('#EEEEEE')
                        }
                        .width('100%')
                        .height('100%')
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.Center)
                      }
                      .width('100%')
                      .height('85%')
                      .backgroundColor('#F8F9FA')
                      .borderRadius(4)
                    }
                    .width('100%')
                    .height(300)
                    .backgroundColor(Color.White)
                    .borderRadius(8)
                    .padding(16)
                  }

                  // 地区分布图
                  GridItem() {
                    Column() {
                      Text('地区分布')
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.textColor)
                        .margin({ bottom: 16 })

                      // 模拟图表内容
                      Row() {
                        Column() {
                          Divider().height(1).color('#EEEEEE')
                          Text('暂无数据')
                            .fontSize(14)
                            .fontColor(this.textColorSecondary)
                            .margin({ top: 100 })
                          Divider().height(1).color('#EEEEEE')
                        }
                        .width('100%')
                        .height('100%')
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.Center)
                      }
                      .width('100%')
                      .height('85%')
                      .backgroundColor('#F8F9FA')
                      .borderRadius(4)
                    }
                    .width('100%')
                    .height(300)
                    .backgroundColor(Color.White)
                    .borderRadius(8)
                    .padding(16)
                  }

                  // 24小时分布图
                  GridItem() {
                    Column() {
                      Text('24小时分布')
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.textColor)
                        .margin({ bottom: 16 })

                      // 模拟图表内容
                      Row() {
                        Column() {
                          Divider().height(1).color('#EEEEEE')
                          Text('暂无数据')
                            .fontSize(14)
                            .fontColor(this.textColorSecondary)
                            .margin({ top: 100 })
                          Divider().height(1).color('#EEEEEE')
                        }
                        .width('100%')
                        .height('100%')
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.Center)
                      }
                      .width('100%')
                      .height('85%')
                      .backgroundColor('#F8F9FA')
                      .borderRadius(4)
                    }
                    .width('100%')
                    .height(300)
                    .backgroundColor(Color.White)
                    .borderRadius(8)
                    .padding(16)
                  }

                  // IP分布图
                  GridItem() {
                    Column() {
                      Text('IP分布')
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.textColor)
                        .margin({ bottom: 16 })

                      // 模拟图表内容
                      Row() {
                        Column() {
                          Divider().height(1).color('#EEEEEE')
                          Text('暂无数据')
                            .fontSize(14)
                            .fontColor(this.textColorSecondary)
                            .margin({ top: 100 })
                          Divider().height(1).color('#EEEEEE')
                        }
                        .width('100%')
                        .height('100%')
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.Center)
                      }
                      .width('100%')
                      .height('85%')
                      .backgroundColor('#F8F9FA')
                      .borderRadius(4)
                    }
                    .width('100%')
                    .height(300)
                    .backgroundColor(Color.White)
                    .borderRadius(8)
                    .padding(16)
                  }

                  // 一周分布图
                  GridItem() {
                    Column() {
                      Text('一周分布')
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.textColor)
                        .margin({ bottom: 16 })

                      // 模拟图表内容
                      Row() {
                        Column() {
                          Divider().height(1).color('#EEEEEE')
                          Text('暂无数据')
                            .fontSize(14)
                            .fontColor(this.textColorSecondary)
                            .margin({ top: 100 })
                          Divider().height(1).color('#EEEEEE')
                        }
                        .width('100%')
                        .height('100%')
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.Center)
                      }
                      .width('100%')
                      .height('85%')
                      .backgroundColor('#F8F9FA')
                      .borderRadius(4)
                    }
                    .width('100%')
                    .height(300)
                    .backgroundColor(Color.White)
                    .borderRadius(8)
                    .padding(16)
                  }

                  // 操作系统分布图
                  GridItem() {
                    Column() {
                      Text('操作系统')
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.textColor)
                        .margin({ bottom: 16 })

                      // 模拟图表内容
                      Row() {
                        Column() {
                          Divider().height(1).color('#EEEEEE')
                          Text('暂无数据')
                            .fontSize(14)
                            .fontColor(this.textColorSecondary)
                            .margin({ top: 100 })
                          Divider().height(1).color('#EEEEEE')
                        }
                        .width('100%')
                        .height('100%')
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.Center)
                      }
                      .width('100%')
                      .height('85%')
                      .backgroundColor('#F8F9FA')
                      .borderRadius(4)
                    }
                    .width('100%')
                    .height(300)
                    .backgroundColor(Color.White)
                    .borderRadius(8)
                    .padding(16)
                  }

                  // 访问浏览器分布图
                  GridItem() {
                    Column() {
                      Text('访问浏览器')
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.textColor)
                        .margin({ bottom: 16 })

                      // 模拟图表内容
                      Row() {
                        Column() {
                          Divider().height(1).color('#EEEEEE')
                          Text('暂无数据')
                            .fontSize(14)
                            .fontColor(this.textColorSecondary)
                            .margin({ top: 100 })
                          Divider().height(1).color('#EEEEEE')
                        }
                        .width('100%')
                        .height('100%')
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.Center)
                      }
                      .width('100%')
                      .height('85%')
                      .backgroundColor('#F8F9FA')
                      .borderRadius(4)
                    }
                    .width('100%')
                    .height(300)
                    .backgroundColor(Color.White)
                    .borderRadius(8)
                    .padding(16)
                  }

                  // 访客类型分布图
                  GridItem() {
                    Column() {
                      Text('访客类型')
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.textColor)
                        .margin({ bottom: 16 })

                      // 模拟图表内容
                      Row() {
                        Column() {
                          Divider().height(1).color('#EEEEEE')
                          Text('暂无数据')
                            .fontSize(14)
                            .fontColor(this.textColorSecondary)
                            .margin({ top: 100 })
                          Divider().height(1).color('#EEEEEE')
                        }
                        .width('100%')
                        .height('100%')
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.Center)
                      }
                      .width('100%')
                      .height('85%')
                      .backgroundColor('#F8F9FA')
                      .borderRadius(4)
                    }
                    .width('100%')
                    .height(300)
                    .backgroundColor(Color.White)
                    .borderRadius(8)
                    .padding(16)
                  }

                  // 访问网络分布图
                  GridItem() {
                    Column() {
                      Text('访问网络')
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.textColor)
                        .margin({ bottom: 16 })

                      // 模拟图表内容
                      Row() {
                        Column() {
                          Divider().height(1).color('#EEEEEE')
                          Text('暂无数据')
                            .fontSize(14)
                            .fontColor(this.textColorSecondary)
                            .margin({ top: 100 })
                          Divider().height(1).color('#EEEEEE')
                        }
                        .width('100%')
                        .height('100%')
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.Center)
                      }
                      .width('100%')
                      .height('85%')
                      .backgroundColor('#F8F9FA')
                      .borderRadius(4)
                    }
                    .width('100%')
                    .height(300)
                    .backgroundColor(Color.White)
                    .borderRadius(8)
                    .padding(16)
                  }

                  // 访问设备分布图
                  GridItem() {
                    Column() {
                      Text('访问设备')
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.textColor)
                        .margin({ bottom: 16 })

                      // 模拟图表内容
                      Row() {
                        Column() {
                          Divider().height(1).color('#EEEEEE')
                          Text('暂无数据')
                            .fontSize(14)
                            .fontColor(this.textColorSecondary)
                            .margin({ top: 100 })
                          Divider().height(1).color('#EEEEEE')
                        }
                        .width('100%')
                        .height('100%')
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.Center)
                      }
                      .width('100%')
                      .height('85%')
                      .backgroundColor('#F8F9FA')
                      .borderRadius(4)
                    }
                    .width('100%')
                    .height(300)
                    .backgroundColor(Color.White)
                    .borderRadius(8)
                    .padding(16)
                  }
                }
                .columnsTemplate('1fr 1fr')
                .columnsGap(16)
                .rowsGap(16)
                .width('100%')
              }
              .width('100%')
              .height('100%')
              .padding(24)
            }
          }
          .width('100%')
          .padding(24)
        }
        .layoutWeight(1)
        .backgroundColor(this.contentBgColor)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('111%')
    .margin({ top: -40 })
    .backgroundColor(this.contentBgColor)
  }
}