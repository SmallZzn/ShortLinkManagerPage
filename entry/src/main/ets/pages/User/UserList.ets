import { User } from '../../model/i';
import { HttpUtils } from '../../JhCommon/http/HttpUtils';
import { APIs } from '../../JhCommon/http/APIs';
import { JhProgressHUD } from '../../JhCommon/components/JhProgressHUD';
import { JhAESPreferencesUtils } from '../../JhCommon/utils/JhPreferencesUtils';
import promptAction from '@ohos.promptAction';

// 定义对话框按钮选项接口
interface DialogButtonOptions {
  text: string;
  color: string;
}

@Component
export struct UserList {
  // 主题色常量
  readonly themeColor: string = '#1890FF';
  readonly cardBgColor: string = '#FFFFFF';
  readonly textColor: string = '#000000';
  readonly textColorSecondary: string = 'rgba(0, 0, 0, 0.65)';
  readonly borderColorValue: string = '#E5E6EB';
  readonly dangerColor: string = '#FF4D4F';
  readonly themeColorLight: string = '#F2F3F5';
  // 数据状态
  @State userList: Array<User> = [];
  @State currentPage: number = 1;
  @State pageSize: number = 10;
  @State totalPages: number = 1;
  @State searchText: string = '';
  @State username: string = '';
  @State token: string = '';
  @State inputPage: string = ''; // 用于存储输入的页码
  @State pageRangeStart: number = 1;
  @State pageRangeEnd: number = 1;
  @State isViewingDisabled: boolean = false;
  @State searchDisplayText: string = ''; // 添加用于显示在搜索框中的文本
  @State viewMode: string = 'all'; // 查看模式：'all'=所有用户, 'enabled'=启用用户, 'disabled'=禁用用户

  aboutToAppear() {
    // 初始化 UI 上下文
    let uiContext: UIContext = this.getUIContext() as UIContext;
    JhProgressHUD.initUIConfig(uiContext);

    // 获取用户凭证
    this.username = JhAESPreferencesUtils.getString("username") || '';
    this.token = JhAESPreferencesUtils.getString("token") || '';

    // 获取用户列表
    this.fetchUserList();
  }

  // 获取用户列表
  private async fetchUserList() {
    try {
      const params: object = Object({
        current: this.currentPage,
        size: this.pageSize,
        username: this.searchText
      });

      // 根据查看模式添加状态过滤
      if (this.viewMode !== 'all') {
        params['delFlag'] = this.viewMode === 'disabled' ? 1 : 0;
      }

      const res = await HttpUtils.get(APIs.pageUserList, params);
      if (res.code === '0') {
        this.userList = res.data.records;
        this.totalPages = Math.ceil(res.data.total / this.pageSize);
        // 计算页码范围
        this.calculatePageRange();
      } else {
        JhProgressHUD.showError('获取用户列表失败');
      }
    } catch (error) {
      console.error('获取用户列表失败:', error);
      JhProgressHUD.showError('获取用户列表失败');
    }
  }

  // 处理搜索
  private handleSearch(value: string) {
    this.searchText = value;
    this.currentPage = 1; // 重置到第一页
    this.fetchUserList();
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

  // 更新用户状态
  private async updateUserStatus(user: User) {
    try {
      JhProgressHUD.showLoading('处理中...');

      // 构建请求参数
      const params: object = Object({
        id: user.id,
        username: user.username,
        delFlag: user.delFlag === 1 ? 0 : 1  // 切换状态
      });

      // 调用API
      const res = await HttpUtils.put(APIs.updateUser, params);

      if (res.code === '0') {
        JhProgressHUD.showSuccess(user.delFlag === 1 ? '启用成功' : '禁用成功');

        // 刷新用户列表
        this.fetchUserList();
      } else {
        JhProgressHUD.showError(user.delFlag === 1 ? '启用失败' : '禁用失败');
      }
    } catch (error) {
      console.error('更新用户状态失败:', error);
      JhProgressHUD.showError(user.delFlag === 1 ? '启用失败' : '禁用失败');
    } finally {
      JhProgressHUD.dismiss();
    }
  }

  build() {
    Column() {
      // 操作栏
      Row() {
        // 搜索框区域
        Row({ space: 8 }) {
          Row() {
            Search({ placeholder: '请输入用户名搜索', value: this.searchDisplayText })
              .width('100%')
              .height(36)
              .backgroundColor(Color.White)
              .borderRadius(2)
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
              this.viewMode = 'all';
              this.searchText = '';
              this.searchDisplayText = '';
              this.fetchUserList();
            })

          // 查看用户状态按钮
          Button(this.viewMode === 'all' ? '查看禁用用户' : 
                 this.viewMode === 'disabled' ? '查看启用用户' : '查看所有用户')
            .height(36)
            .backgroundColor(this.viewMode === 'all' ? this.dangerColor : 
                           this.viewMode === 'disabled' ? '#52C41A' : this.themeColor)
            .fontColor(Color.White)
            .fontSize(14)
            .borderRadius(2)
            .onClick(() => {
              // 切换查看模式：all -> disabled -> enabled -> all
              if (this.viewMode === 'all') {
                this.viewMode = 'disabled';
              } else if (this.viewMode === 'disabled') {
                this.viewMode = 'enabled';
              } else {
                this.viewMode = 'all';
              }
              this.fetchUserList();
            })
        }
        .width('40%')
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .margin({ bottom: 12, top: -8 })
      .justifyContent(FlexAlign.SpaceBetween)

      // 用户列表
      Column() {
        // 表头
        Row() {
          Text('用户名')
            .width('20%')
            .fontSize(14)
            .fontColor(this.textColorSecondary)
            .textAlign(TextAlign.Center)
          Text('电话号码')
            .width('20%')
            .fontSize(14)
            .fontColor(this.textColorSecondary)
            .textAlign(TextAlign.Center)
          Text('邮箱')
            .width('20%')
            .fontSize(14)
            .fontColor(this.textColorSecondary)
            .textAlign(TextAlign.Center)
          Text('是否禁用')
            .width('10%')
            .fontSize(14)
            .fontColor(this.textColorSecondary)
            .textAlign(TextAlign.Center)
          Text('创建时间')
            .width('15%')
            .fontSize(14)
            .fontColor(this.textColorSecondary)
            .textAlign(TextAlign.Center)
          Text('操作')
            .width('15%')
            .fontSize(14)
            .fontColor(this.textColorSecondary)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height(45)
        .padding({ left: 16, right: 16 })
        .backgroundColor(this.cardBgColor)

        List() {
          // 用户数据
          ForEach(this.userList, (user: User) => {
            ListItem() {
              Row() {
                Text(user.username)
                  .width('20%')
                  .fontSize(14)
                  .fontColor(this.textColorSecondary)
                  .textAlign(TextAlign.Center)
                Text(user.phone)
                  .width('20%')
                  .fontSize(14)
                  .fontColor(this.textColorSecondary)
                  .textAlign(TextAlign.Center)
                Text(user.mail)
                  .width('20%')
                  .fontSize(14)
                  .fontColor(this.textColorSecondary)
                  .textAlign(TextAlign.Center)
                Text(user.delFlag === 1 ? '是' : '否')
                  .width('10%')
                  .fontSize(14)
                  .fontColor(user.delFlag === 1 ? this.dangerColor : this.textColorSecondary)
                  .textAlign(TextAlign.Center)
                Text(user.createTime ? this.formatDate(user.createTime) : '')
                  .width('15%')
                  .fontSize(14)
                  .fontColor(this.textColorSecondary)
                  .textAlign(TextAlign.Center)
                Row({ space: 8 }) {
                  Button(user.delFlag === 1 ? '启用' : '禁用')
                    .height(32)
                    .backgroundColor(user.delFlag === 1 ? this.themeColor : this.dangerColor)
                    .fontColor(Color.White)
                    .fontSize(14)
                    .borderRadius(2)
                    .onClick(() => {
                      promptAction.showDialog({
                        title: user.delFlag === 1 ? '启用确认' : '禁用确认',
                        message: user.delFlag === 1 ?
                          '确定要启用该用户吗？\n' :
                          '确定要禁用该用户吗？\n',
                        buttons: [
                          {
                            text: '取消',
                            color: '#666666',
                          } as DialogButtonOptions,
                          {
                            text: user.delFlag === 1 ? '确定启用' : '确定禁用',
                            color: user.delFlag === 1 ? this.themeColor : this.dangerColor,
                          } as DialogButtonOptions
                        ],
                      })
                        .then((result) => {
                          if (result.index === 1) {
                            // 调用更新API，传入用户信息和状态
                            this.updateUserStatus(user);
                          }
                        })
                    })
                }
                .width('15%')
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
              this.fetchUserList();
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
                this.fetchUserList();
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
              this.fetchUserList();
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
                this.fetchUserList();
                this.inputPage = '';
              } else {
                JhProgressHUD.showText('请输入有效页码');
              }
            })
        }
        .layoutWeight(2)
        .justifyContent(FlexAlign.Center)

        // 总条数显示在右侧
        Text(`共 ${this.userList.length} 条`)
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
  }
}
