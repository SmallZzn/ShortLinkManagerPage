import { JhProgressHUD } from "../../JhCommon/components/JhProgressHUD";
import { APIs } from "../../JhCommon/http/APIs";
import { HttpUtils } from "../../JhCommon/http/HttpUtils";
import { ShortLink } from "../../model/ShortLinkInterface";
import { JhAESPreferencesUtils } from "../../JhCommon/utils/JhPreferencesUtils";
import systemPasteboard from '@ohos.pasteboard';
import { ShortLinkStats } from "./ShortLinkStats";
import router from '@ohos.router';

interface ManagerToUserDO {
  id: number;
  managerName: string;
  username: string;
  userType: number;
}

interface SelectOption {
  value: string;
  text: string;
}

@Component
export struct ShortLinkList {
  // 主题色常量
  readonly themeColor: string = '#1890FF';
  readonly cardBgColor: string = '#FFFFFF';
  readonly textColor: string = '#000000';
  readonly textColorSecondary: string = 'rgba(0, 0, 0, 0.65)';
  readonly borderColorValue: string = '#E5E6EB';
  readonly dangerColor: string = '#FF4D4F';
  readonly successColor: string = '#52C41A';
  readonly themeColorLight: string = '#F2F3F5';
  // 数据状态
  @State shortLinkList: Array<ShortLink> = [];
  @State currentPage: number = 1;
  @State pageSize: number = 6;
  @State totalPages: number = 1;
  @State totalCount: number = 0;
  @State manager: string = '';
  @State token: string = '';
  @State inputPage: string = '';
  @State pageRangeStart: number = 1;
  @State pageRangeEnd: number = 1;
  @State isStatsDrawerOpening: boolean = false;
  @State statsDrawerWidth: number = 0;
  @State currentEditLink: ShortLink | null = null;
  // 下拉框数据
  @State userList: Array<string> = [];
  @State selectedUser: string = '';
  @State selectedUserIndex: number = 0;
  // 用户类型数据
  @State userTypeList: Array<SelectOption> = [
    { value: '1', text: '个人用户' },
    { value: '0', text: '公司' }
  ];
  @State selectedUserType: string = '1';
  @State selectedUserTypeIndex: number = 0;
  // 添加回调函数
  onShowStats?: (item: ShortLink) => void;

  aboutToAppear() {
    // 初始化 UI 上下文
    let uiContext: UIContext = this.getUIContext() as UIContext;
    JhProgressHUD.initUIConfig(uiContext);

    // 获取用户凭证
    this.manager = JhAESPreferencesUtils.getString("username") || '';
    this.token = JhAESPreferencesUtils.getString("token") || '';

    // 获取下拉框数据
    this.fetchUserList();
  }

  aboutToDisappear() {
    // 在组件销毁前做清理工作
  }

  // 获取下拉框数据
  private async fetchUserList() {
    try {
      const res = await HttpUtils.get(APIs.listByManagerName + this.manager, {});
      if (res.code === '0') {
        this.userList = res.data;
        if (this.userList.length > 0) {
          this.selectedUser = this.userList[0];
          this.selectedUserIndex = 0;
          // 获取短链接列表
          this.fetchShortLinkList();
        }
      } else {
        JhProgressHUD.showError('获取数据失败');
      }
    } catch (error) {
      console.error('获取数据失败:', error);
      JhProgressHUD.showError('获取数据失败');
    }
  }

  // 获取短链接列表
  private async fetchShortLinkList() {
    try {
      const params: object = Object({
        current: this.currentPage,
        size: this.pageSize,
        managerName: this.manager,
        username: this.selectedUser
      });

      const res = await HttpUtils.post(APIs.getManagerShortLink, params);
      if (res.code === '0') {
        this.shortLinkList = res.data.records;
        this.totalCount = res.data.total;
        this.totalPages = Math.ceil(res.data.total / this.pageSize);
        this.calculatePageRange();
      } else {
        JhProgressHUD.showError('获取短链接列表失败');
      }
    } catch (error) {
      console.error('获取短链接列表失败:', error);
      JhProgressHUD.showError('获取短链接列表失败');
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
  private formatDate(dateStr: string): string {
    if (!dateStr) {
      return '';
    }
    const date = new Date(dateStr);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  // 检查短链接是否过期
  private isLinkExpired(item: ShortLink): boolean {
    // 永久有效的链接永远不会过期
    if (item.validDateType === 0) {
      return false;
    }

    // 获取当前日期
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate()); // 设置为今天的0点0分0秒

    // 获取有效期日期字符串
    const validDateStr = item.validDate;
    if (!validDateStr) {
      return false; // 没有有效期信息，当作未过期
    }

    // 解析有效期日期
    const validDate = new Date(validDateStr);
    // 将validDate也设置为其当天的0点0分0秒，用于比较日期
    const validDay = new Date(validDate.getFullYear(), validDate.getMonth(), validDate.getDate());

    // 比较当前日期与有效期，如果validDay等于today，不算过期
    // 只有当today大于validDay时才算过期
    return today > validDay;
  }

  // 复制链接到剪贴板
  private async copyToClipboard(text: string): Promise<void> {
    try {
      // 获取系统剪贴板实例
      const pasteboard = systemPasteboard.getSystemPasteboard();

      // 创建 PasteData 对象并写入文本
      const pasteData = systemPasteboard.createData('text/plain', text);

      // 写入剪贴板
      await pasteboard.setData(pasteData);

      // 显示成功提示
      JhProgressHUD.showSuccess('链接已复制');
    } catch (error) {
      console.error('复制失败:', error);
      JhProgressHUD.showError('复制失败');
    }
  }

  // 显示统计信息
  private showStats(item: ShortLink) {
    this.currentEditLink = item;
    this.isStatsDrawerOpening = true;
    this.statsDrawerWidth = 700; // 缩小宽度
  }

  // 生成页码
  private generatePageNumbers(currentPage: number, totalPages: number): Array<string> {
    const result: Array<string> = [];
    const pagesToDisplay = 5; // 修改为显示5个页码

    // 计算起始和结束页码
    let startPage = currentPage - Math.floor((pagesToDisplay - 1) / 2);
    let endPage = currentPage + Math.floor((pagesToDisplay - 1) / 2);

    // 调整起始和结束页码
    if (startPage < 1) {
      startPage = 1;
      endPage = Math.min(pagesToDisplay, totalPages);
    }

    if (endPage > totalPages) {
      endPage = totalPages;
      startPage = Math.max(1, totalPages - pagesToDisplay + 1);
    }

    // 如果总页数小于等于5，直接显示所有页码
    if (totalPages <= pagesToDisplay) {
      for (let i = 1; i <= totalPages; i++) {
        result.push(i.toString());
      }
    } else {
      // 添加首页链接
      result.push("<");

      // 添加第一页和省略号
      if (startPage > 1) {
        result.push("1");
        if (startPage > 2) {
          result.push("...");
        }
      }

      // 添加中间页码
      for (let i = startPage; i <= endPage; i++) {
        result.push(i.toString());
      }

      // 添加省略号和最后一页
      if (endPage < totalPages) {
        if (endPage < totalPages - 1) {
          result.push("...");
        }
        result.push(totalPages.toString());
      }

      // 添加尾页链接
      result.push(">");
    }

    return result;
  }

  build() {
    Stack() {
      Column() {
        // 标题
        Text('短链接列表')
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
            .optionHeight(240)// 限制下拉选项高度，约显示6项
            .width(200)
            .height(36)
            .backgroundColor(Color.White)
            .borderRadius(2)
            .border({ width: 1, color: this.borderColorValue })
            .onSelect((index: number) => {
              this.selectedUserIndex = index;
              this.selectedUser = this.userList[index];
              this.currentPage = 1;
              this.fetchShortLinkList();
            })
            .margin({ right: 12 })

          Button('搜索')
            .height(36)
            .backgroundColor(this.themeColor)
            .fontColor(Color.White)
            .fontSize(14)
            .borderRadius(2)
            .onClick(() => {
              this.currentPage = 1;
              this.fetchShortLinkList();
            })
        }
        .width('100%')
        .margin({ bottom: 12 })
        .justifyContent(FlexAlign.Start)

        // 短链接列表
        Column() {
          // 表头
          Row() {
            // 短链接信息列
            Text('短链接信息')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.textColorSecondary)
              .layoutWeight(2)
              .margin({ left: 24 })

            // 短链接列
            Text('短链接')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.textColorSecondary)
              .layoutWeight(3)
              .margin({ left: 90 })

            // 访问次数列
            Text('访问次数')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.textColorSecondary)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
              .margin({ left: 15 })

            // 访问人数列
            Text('访问人数')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.textColorSecondary)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
              .margin({ left: 10 })

            // IP数列
            Text('IP数')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.textColorSecondary)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            // 操作列
            Text('操作')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.textColorSecondary)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .height(48)
          .backgroundColor(this.themeColorLight)
          .padding({ right: 24 })

          // 数据列表
          List({ space: 1 }) {
            ForEach(this.shortLinkList, (item: ShortLink) => {
              ListItem() {
                Row() {
                  // 短链接信息
                  Column() {
                    if (item.describe) {
                      Text(item.describe)
                        .fontSize(13)
                        .fontColor(this.isLinkExpired(item) ? this.textColorSecondary : this.textColor)
                        .margin({ bottom: 4 })
                        .opacity(this.isLinkExpired(item) ? 0.6 : 1)
                    }

                    Row() {
                      Text(this.formatDate(item.createTime))
                        .fontSize(11)
                        .fontColor(this.textColorSecondary)
                        .opacity(this.isLinkExpired(item) ? 0.6 : 1)

                      // 添加过期标签
                      if (this.isLinkExpired(item)) {
                        Text('已失效')
                          .fontSize(10)
                          .backgroundColor('#ff4d4f')
                          .fontColor(Color.White)
                          .borderRadius(2)
                          .padding({
                            left: 4,
                            right: 4,
                            top: 1,
                            bottom: 1
                          })
                          .margin({ left: 6 })
                      }
                    }
                  }
                  .layoutWeight(2)
                  .alignItems(HorizontalAlign.Start)

                  // 短链接
                  Column() {
                    Row() {
                      Text(item.domain + item.shortUri)
                        .fontSize(13)
                        .fontColor(this.isLinkExpired(item) ? this.textColorSecondary : '#007AFF')
                        .margin({ bottom: 4 })
                        .opacity(this.isLinkExpired(item) ? 0.6 : 1)
                        .onClick(() => {
                          if (!this.isLinkExpired(item)) {
                            router.pushUrl({
                              url: 'pages/Statistics/Access',
                              params: {
                                shortLink: item
                              }
                            });
                          }
                        })

                      Button({ type: ButtonType.Circle }) {
                        Image($r('app.media.share'))
                          .width(16)
                          .height(16)
                          .fillColor(this.textColorSecondary)
                      }
                      .width(32)
                      .height(32)
                      .backgroundColor(Color.White)
                      .enabled(!this.isLinkExpired(item)) // 禁用过期链接的复制按钮
                      .opacity(this.isLinkExpired(item) ? 0.5 : 1)
                      .onClick(() => {
                        if (!this.isLinkExpired(item)) {
                          this.copyToClipboard(item.domain + item.shortUri || '');
                        }
                      })
                    }

                    Text(item.originUrl)
                      .fontSize(11)
                      .fontColor(this.textColorSecondary)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(1)
                      .opacity(this.isLinkExpired(item) ? 0.6 : 1)
                  }
                  .layoutWeight(3)
                  .alignItems(HorizontalAlign.Start)

                  // 访问量(PV)
                  Column() {
                    Text('今日：' + (item.todayPv || 0))
                      .fontSize(13)
                      .fontColor(this.isLinkExpired(item) ? this.textColorSecondary : this.textColor)
                      .margin({ bottom: 4 })
                      .opacity(this.isLinkExpired(item) ? 0.6 : 1)

                    Text('总计：' + (item.totalPv || 0))
                      .fontSize(13)
                      .fontColor(this.textColorSecondary)
                      .opacity(this.isLinkExpired(item) ? 0.6 : 1)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Center)

                  // 访客数(UV)
                  Column() {
                    Text('今日：' + (item.todayUv || 0))
                      .fontSize(13)
                      .fontColor(this.isLinkExpired(item) ? this.textColorSecondary : this.textColor)
                      .margin({ bottom: 4 })
                      .opacity(this.isLinkExpired(item) ? 0.6 : 1)

                    Text('总计：' + (item.totalUv || 0))
                      .fontSize(13)
                      .fontColor(this.textColorSecondary)
                      .opacity(this.isLinkExpired(item) ? 0.6 : 1)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Center)

                  // 访问IP数
                  Column() {
                    Text('今日：' + (item.todayUip || 0))
                      .fontSize(13)
                      .fontColor(this.isLinkExpired(item) ? this.textColorSecondary : this.textColor)
                      .margin({ bottom: 4 })
                      .opacity(this.isLinkExpired(item) ? 0.6 : 1)

                    Text('总计：' + (item.totalUip || 0))
                      .fontSize(13)
                      .fontColor(this.textColorSecondary)
                      .opacity(this.isLinkExpired(item) ? 0.6 : 1)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Center)

                  // 操作列
                  Row({ space: 12 }) {
                    // 统计图标
                    Image($r("app.media.tj"))
                      .width(16)
                      .height(16)
                      .fillColor(this.textColor)
                      .onClick(() => {
                        this.showStats(item);
                      })
                  }
                  .layoutWeight(1)
                  .justifyContent(FlexAlign.Center)
                }
                .width('100%')
                .padding({
                  left: 24,
                  right: 24,
                  top: 12,
                  bottom: 12
                })
                .backgroundColor(Color.White)
                .borderRadius(8)
                // 为过期的链接添加灰色背景
                .opacity(this.isLinkExpired(item) ? 0.9 : 1)
              }
            })
          }
          .width('100%')
          .layoutWeight(1)

          // 修改分页器部分
          if (this.shortLinkList && this.shortLinkList.length > 0) {
            Row() {
              // 左侧空白区域
              Blank()
                .layoutWeight(1)

              // 分页控制居中
              Row({ space: 8 }) {
                // 上一页按钮
                Row() {
                  Text('<')
                    .fontSize(14)
                    .fontColor(this.currentPage > 1 ? this.themeColor : this.textColorSecondary)
                }
                .padding(8)
                .backgroundColor(this.themeColorLight)
                .borderRadius(2)
                .enabled(this.currentPage > 1)
                .onClick(() => {
                  if (this.currentPage > 1) {
                    this.currentPage--;
                    this.fetchShortLinkList();
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
                  .borderRadius(2)
                  .onClick(() => {
                    if (page !== this.currentPage) {
                      this.currentPage = page;
                      this.fetchShortLinkList();
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
                .borderRadius(2)
                .enabled(this.currentPage < this.totalPages)
                .onClick(() => {
                  if (this.currentPage < this.totalPages) {
                    this.currentPage++;
                    this.fetchShortLinkList();
                  }
                })

                // 页数信息
                Text(`${this.currentPage}/${this.totalPages}页`)
                  .fontSize(14)
                  .fontColor(this.textColorSecondary)
                  .margin({ left: 8, right: 8 })

                // 跳转页码输入
                Text('跳至')
                  .fontSize(14)
                  .fontColor(this.textColorSecondary)

                TextInput({ text: this.inputPage })
                  .width(40)
                  .height(32)
                  .backgroundColor(this.themeColorLight)
                  .borderRadius(2)
                  .type(InputType.Number)
                  .onChange((value: string) => {
                    this.inputPage = value;
                  })

                Text('页')
                  .fontSize(14)
                  .fontColor(this.textColorSecondary)

                Button('确定')
                  .fontSize(14)
                  .fontColor(Color.White)
                  .backgroundColor(this.themeColor)
                  .borderRadius(2)
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
                      this.fetchShortLinkList();
                      this.inputPage = '';
                    } else {
                      JhProgressHUD.showText('请输入有效页码');
                    }
                  })
              }
              .layoutWeight(2)
              .justifyContent(FlexAlign.Center)

              // 总条数显示在右侧
              Text(`共 ${this.totalCount} 条`)
                .fontSize(14)
                .fontColor(this.textColorSecondary)
                .layoutWeight(1)
                .textAlign(TextAlign.End)
            }
            .width('100%')
            .height(56)
            .padding({ left: 16, right: 16 })
            .backgroundColor(Color.White)
            .border({ width: { top: 1 }, color: this.borderColorValue })
            .margin({ bottom: 50 })
          }
        }
        .width('98%')
        .backgroundColor(Color.White)
        .borderRadius(8)
        .border({ width: 1, color: this.borderColorValue })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F2F3F5')
      .padding({ top: 10, bottom: 24 })
      
      // 统计抽屉
      if (this.isStatsDrawerOpening && this.currentEditLink) {
        ShortLinkStats({
          isStatsDrawerOpening: $isStatsDrawerOpening,
          statsDrawerWidth: $statsDrawerWidth,
          shortLink: this.currentEditLink,
          onSuccess: () => {
            // 关闭后的回调
          }
        })
        .width('100%')
        .height('100%')
        .position({ x: -190, y: 0 }) // 向左移动一些
        .backgroundColor(Color.White)
        .borderRadius(8)
        .zIndex(1)
        .margin({ left: 0, right: 0, top: 0, bottom: 0 })
      }
    }
    .width('100%')
    .height('100%')
  }
}

// 创建一个新的容器组件来包裹 ShortLinkList
@Component
export struct ShortLinkListContainer {
  @State isStatsDrawerOpening: boolean = false;
  @State statsDrawerWidth: number = 0;
  @State currentEditLink: ShortLink | null = null;
  // 添加主题色常量
  readonly borderColorValue: string = '#E5E6EB';

  build() {
    Stack() {
      ShortLinkList({
        onShowStats: (item: ShortLink) => {
          this.currentEditLink = item;
          this.isStatsDrawerOpening = true;
          this.statsDrawerWidth = 700; // 缩小宽度
        }
      })

      // 统计抽屉
      if (this.isStatsDrawerOpening && this.currentEditLink) {
        ShortLinkStats({
          isStatsDrawerOpening: $isStatsDrawerOpening,
          statsDrawerWidth: $statsDrawerWidth,
          shortLink: this.currentEditLink,
          onSuccess: () => {
            // 关闭后的回调
          }
        })
        .width('100%')
        .height('100%')
        .position({ x: -50, y: 0 }) // 向左移动一些
        .backgroundColor(Color.White)
        .borderRadius(8)
        .border({ width: 1, color: this.borderColorValue })
        .zIndex(1)
        .margin({ left: 0, right: 0, top: 0, bottom: 0 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
