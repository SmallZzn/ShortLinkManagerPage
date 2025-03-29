import { HttpUtils } from '../../JhCommon/http/HttpUtils';
import { APIs } from '../../JhCommon/http/APIs';
import { JhProgressHUD } from '../../JhCommon/components/JhProgressHUD';
import { JhAESPreferencesUtils } from '../../JhCommon/utils/JhPreferencesUtils';
import promptAction from '@ohos.promptAction';

// 定义黑名单项接口
interface BlackListItem {
  id: number; // ID
  blackName: string; // 黑名单域名
  reason: string; // 禁用原因
  createTime: string; // 创建时间
  updateTime: string; // 更新时间
}

// 定义对话框按钮选项接口
interface DialogButtonOptions {
  text: string;
  color: string;
}

// 添加黑名单抽屉组件
@CustomDialog
struct AddBlackListDialog {
  controller: CustomDialogController;
  onSuccess: () => Promise<void> = () => {
    return Promise.resolve();
  }; // 添加默认初始化
  // 主题色常量
  private themeColor: string = '#1890FF';
  private textColor: string = '#000000';
  private textColorSecondary: string = 'rgba(0, 0, 0, 0.65)';
  private borderColorValue: string = '#E5E6EB';
  private placeholderColor: string = 'rgba(0, 0, 0, 0.35)'; // 更浅的提示文字颜色
  @State blackName: string = '';
  @State reason: string = '';

  // 重置表单
  private resetForm() {
    this.blackName = '';
    this.reason = '';
  }

  // 关闭对话框
  private closeDialog() {
    this.resetForm();
    this.controller.close();
  }

  // 添加黑名单
  private async addBlackList() {
    // 检查输入是否为空
    if (!this.blackName.trim()) {
      JhProgressHUD.showText('请输入域名');
      return;
    }

    if (!this.reason.trim()) {
      JhProgressHUD.showText('请输入禁用原因');
      return;
    }

    try {
      const params: object = Object({
        blackName: this.blackName.trim(),
        reason: this.reason.trim()
      });

      const res = await HttpUtils.post(APIs.addBlackList, params);

      if (res.code === '0') {
        JhProgressHUD.showSuccess('添加黑名单成功');
        this.resetForm();
        this.controller.close();
        // 重置当前页为第一页，确保能看到新添加的记录
        this.onSuccess(); // 回调刷新列表
      } else {
        JhProgressHUD.showError('添加黑名单失败: ' + res.message);
      }
    } catch (error) {
      console.error('添加黑名单失败:', error);
      JhProgressHUD.showError('添加黑名单失败');
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('添加黑名单')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.textColor)

        Blank()

        Button() {
          Text('✕')// 使用文本替代图标
            .fontSize(16)
            .fontColor(this.textColorSecondary)
        }
        .backgroundColor(Color.Transparent)
        .width(32)
        .height(32)
        .onClick(() => {
          this.closeDialog();
        })
      }
      .width('100%')
      .padding({
        left: 24,
        right: 16,
        top: 16,
        bottom: 16
      })
      .justifyContent(FlexAlign.SpaceBetween)

      // 表单内容
      Column({ space: 20 }) {
        // 域名输入
        Column({ space: 8 }) {
          Text('域名')
            .fontSize(14)
            .fontColor(this.textColor)
            .fontWeight(FontWeight.Medium)

          TextInput({ placeholder: '请输入域名' })
            .placeholderColor(this.placeholderColor)
            .height(40)
            .width('100%')
            .backgroundColor(Color.White)
            .border({ width: 1, color: this.borderColorValue, radius: 4 })
            .padding({ left: 12, right: 12 })
            .onChange((value) => {
              this.blackName = value;
            })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')

        // 禁用原因输入
        Column({ space: 8 }) {
          Text('禁用原因')
            .fontSize(14)
            .fontColor(this.textColor)
            .fontWeight(FontWeight.Medium)

          TextArea({ placeholder: '请输入禁用原因' })
            .placeholderColor(this.placeholderColor)
            .height(120)
            .width('100%')
            .backgroundColor(Color.White)
            .border({ width: 1, color: this.borderColorValue, radius: 4 })
            .padding(12)
            .onChange((value) => {
              this.reason = value;
            })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }
      .padding({ left: 24, right: 24, bottom: 24 })
      .width('100%')

      // 底部按钮
      Row({ space: 16 }) {
        Button('取消')
          .height(40)
          .fontColor(this.textColorSecondary)
          .backgroundColor(Color.White)
          .borderRadius(4)
          .border({ width: 1, color: this.borderColorValue })
          .layoutWeight(1)
          .onClick(() => {
            this.closeDialog();
          })

        Button('确定')
          .height(40)
          .fontColor(Color.White)
          .backgroundColor(this.themeColor)
          .borderRadius(4)
          .layoutWeight(1)
          .onClick(() => {
            this.addBlackList();
          })
      }
      .padding({ left: 24, right: 24, bottom: 24 })
      .width('100%')
    }
    .width(480)
    .backgroundColor(Color.White)
    .borderRadius(8)
  }
}

@Component
export struct BlackList {
  // 主题色常量
  readonly themeColor: string = '#1890FF';
  readonly cardBgColor: string = '#FFFFFF';
  readonly textColor: string = '#000000';
  readonly textColorSecondary: string = 'rgba(0, 0, 0, 0.65)';
  readonly borderColorValue: string = '#E5E6EB';
  readonly dangerColor: string = '#FF4D4F';
  readonly successColor: string = '#52C41A';
  readonly themeColorLight: string = '#F2F3F5';
  readonly placeholderColor: string = 'rgba(0, 0, 0, 0.35)'; // 更浅的提示文字颜色
  // 数据状态
  @State blackList: Array<BlackListItem> = [];
  @State currentPage: number = 1;
  @State pageSize: number = 10;
  @State totalPages: number = 1;
  @State totalRecords: number = 0;
  @State searchText: string = '';
  @State username: string = '';
  @State token: string = '';
  @State inputPage: string = ''; // 用于存储输入的页码
  @State pageRangeStart: number = 1;
  @State pageRangeEnd: number = 1;
  @State searchDisplayText: string = ''; // 添加用于显示在搜索框中的文本
  @State isLoading: boolean = false;
  // 添加黑名单对话框控制器
  addBlackListDialogController: CustomDialogController = new CustomDialogController({
    builder: AddBlackListDialog({
      onSuccess: (): Promise<void> => {
        // 强制返回第一页，确保能看到新添加的记录
        this.currentPage = 1;
        return this.fetchBlackList();
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: true
  });

  aboutToAppear() {
    // 初始化 UI 上下文
    let uiContext: UIContext = this.getUIContext() as UIContext;
    JhProgressHUD.initUIConfig(uiContext);

    // 获取用户凭证
    this.username = JhAESPreferencesUtils.getString("username") || '';
    this.token = JhAESPreferencesUtils.getString("token") || '';

    // 获取黑名单列表
    this.fetchBlackList();
  }

  // 获取黑名单列表
  private async fetchBlackList() {
    try {
      this.isLoading = true;
      const params: object = Object({
        current: this.currentPage,
        size: this.pageSize,
        blackName: this.searchText
      });

      const res = await HttpUtils.get(APIs.pageBlackList, params);
      if (res.code === '0') {
        this.blackList = res.data.records;
        this.totalPages = Math.ceil(res.data.total / this.pageSize);
        this.totalRecords = res.data.total;
        // 计算页码范围
        this.calculatePageRange();
      } else {
        JhProgressHUD.showError('获取黑名单列表失败');
      }
    } catch (error) {
      console.error('获取黑名单列表失败:', error);
      JhProgressHUD.showError('获取黑名单列表失败');
    } finally {
      this.isLoading = false;
    }
  }

  // 处理搜索
  private handleSearch(value: string) {
    this.searchText = value;
    this.currentPage = 1; // 重置到第一页
    this.fetchBlackList();
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

  // 格式化日期，只显示年月日
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

  // 删除黑名单
  private async deleteBlackList(item: BlackListItem) {
    try {
      const params: Object = Object({
        id: item.id,
        blackName: item.blackName,
        reason: item.reason,
        delFlag: 1
      });

      // 调用API
      const res = await HttpUtils.put(APIs.updateBlackList, params);

      if (res.code === '0') {
        JhProgressHUD.showSuccess('删除黑名单成功');
        // 刷新黑名单列表
        this.fetchBlackList();
      } else {
        JhProgressHUD.showError('删除黑名单失败');
      }
    } catch (error) {
      console.error('删除黑名单失败:', error);
      JhProgressHUD.showError('删除黑名单失败');
    }
  }

  build() {
    Stack() {
      // 主内容区域
      Column() {
        // 标题
        Text('黑名单列表')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.textColor)
          .margin({ bottom: 16 })
          .alignSelf(ItemAlign.Start)

        // 操作栏
        Row() {
          // 搜索框区域
          Row({ space: 8 }) {
            Row() {
              Search({ placeholder: '请输入域名搜索', value: this.searchDisplayText })
                .width('100%')
                .height(36)
                .backgroundColor(Color.White)
                .borderRadius(2)
                .placeholderColor(this.placeholderColor)
                .border({ width: 1, color: this.borderColorValue })
                .onChange((value: string) => {
                  this.searchText = value;
                  this.searchDisplayText = value;
                })
                .onSubmit((value: string) => {
                  this.handleSearch(value);
                })
            }
            .width('80%')
          }
          .width('60%')

          // 按钮组
          Row({ space: 8 }) {
            // 重置按钮
            Button('重置')
              .height(36)
              .backgroundColor(this.themeColor)
              .fontColor(Color.White)
              .fontSize(14)
              .borderRadius(2)
              .onClick(() => {
                this.searchText = '';
                this.searchDisplayText = '';
                this.fetchBlackList();
              })

            // 添加黑名单按钮
            Button('添加黑名单')
              .height(36)
              .backgroundColor(this.themeColor)
              .fontColor(Color.White)
              .fontSize(14)
              .borderRadius(2)
              .onClick(() => {
                this.addBlackListDialogController.open();
              })
          }
          .width('40%')
          .justifyContent(FlexAlign.End)
        }
        .width('100%')
        .margin({ bottom: 12, top: -8 })
        .justifyContent(FlexAlign.SpaceBetween)

        // 黑名单列表
        Column() {
          // 表头
          Row() {
            Text('序号')
              .width('10%')
              .fontSize(14)
              .fontColor(this.textColorSecondary)
              .textAlign(TextAlign.Center)
            Text('域名')
              .width('30%')
              .fontSize(14)
              .fontColor(this.textColorSecondary)
              .textAlign(TextAlign.Center)
            Text('禁用原因')
              .width('35%')
              .fontSize(14)
              .fontColor(this.textColorSecondary)
              .textAlign(TextAlign.Center)
            Text('创建时间')
              .width('15%')
              .fontSize(14)
              .fontColor(this.textColorSecondary)
              .textAlign(TextAlign.Center)
            Text('操作')
              .width('10%')
              .fontSize(14)
              .fontColor(this.textColorSecondary)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .height(45)
          .padding({ left: 16, right: 16 })
          .backgroundColor(this.cardBgColor)

          List() {
            // 黑名单数据
            ForEach(this.blackList, (item: BlackListItem, index: number) => {
              ListItem() {
                Row() {
                  Text(`${(this.currentPage - 1) * this.pageSize + index + 1}`)
                    .width('10%')
                    .fontSize(14)
                    .fontColor(this.textColorSecondary)
                    .textAlign(TextAlign.Center)
                  Text(item.blackName || '未知域名')
                    .width('30%')
                    .fontSize(14)
                    .fontColor(this.textColorSecondary)
                    .textAlign(TextAlign.Center)
                  Text(item.reason || '未知原因')
                    .width('35%')
                    .fontSize(14)
                    .fontColor(this.textColorSecondary)
                    .textAlign(TextAlign.Center)
                  Text(item.createTime ? this.formatDate(item.createTime) : '未知')
                    .width('15%')
                    .fontSize(14)
                    .fontColor(this.textColorSecondary)
                    .textAlign(TextAlign.Center)

                  // 操作按钮
                  Row({ space: 8 }) {
                    Button('删除')
                      .height(32)
                      .backgroundColor(this.dangerColor)
                      .fontColor(Color.White)
                      .fontSize(14)
                      .borderRadius(2)
                      .onClick(() => {
                        promptAction.showDialog({
                          title: '删除确认',
                          message: `确定要删除该黑名单域名吗？\n${item.blackName}`,
                          buttons: [
                            {
                              text: '取消',
                              color: '#666666',
                            } as DialogButtonOptions,
                            {
                              text: '确定删除',
                              color: this.dangerColor,
                            } as DialogButtonOptions
                          ],
                        })
                          .then((result) => {
                            if (result.index === 1) {
                              // 调用删除API
                              this.deleteBlackList(item);
                            }
                          })
                      })
                  }
                  .width('10%')
                  .justifyContent(FlexAlign.Center) // 按钮居中
                }
                .width('100%')
                .height(50)
                .padding({ left: 16, right: 16 })
                .backgroundColor(Color.White)
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .divider({ strokeWidth: 1, color: this.borderColorValue })
          .backgroundColor(Color.White)
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(Color.White)
        .borderRadius(8)

        // 分页
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
                this.fetchBlackList();
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
                  this.fetchBlackList();
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
                this.fetchBlackList();
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
              .placeholderColor(this.placeholderColor)
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
                  this.fetchBlackList();
                  this.inputPage = '';
                } else {
                  JhProgressHUD.showText('请输入有效页码');
                }
              })
          }
          .layoutWeight(2)
          .justifyContent(FlexAlign.Center)

          // 总条数显示在右侧
          Text(`共 ${this.totalRecords} 条`)
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
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F2F3F5')
      .padding(16) // 添加内边距
      .zIndex(1)
    }
    .width('100%')
    .height('100%')
  }
}
