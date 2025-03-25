import { Manager, User } from '../../model/UserInterface';
import { HttpUtils } from '../../JhCommon/http/HttpUtils';
import { APIs } from '../../JhCommon/http/APIs';
import { JhProgressHUD } from '../../JhCommon/components/JhProgressHUD';
import { JhAESPreferencesUtils } from '../../JhCommon/utils/JhPreferencesUtils';
import promptAction from '@ohos.promptAction';
import { AssignDrawer } from './AssignPage';
import { AddManagerPage } from './AddManagerPage';

// 定义对话框按钮选项接口
interface DialogButtonOptions {
  text: string;
  color: string;
}

// 定义AssignDrawer参数接口
interface AssignDrawerParams {
  manager: Manager;
  onCancel: () => void;
}

@Component
export struct ManagerList {
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
  @State managerList: Array<Manager> = [];
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
  @State viewMode: string = 'all'; // 查看模式：'all'=所有管理员, 'enabled'=启用管理员, 'disabled'=禁用管理员
  
  // 分配抽屉相关状态
  @State isAssignDrawerOpen: boolean = false;
  @State assignDrawerWidth: number = 0;
  @State currentManager: Manager = new Manager();

  // 添加管理员抽屉相关状态
  @State isAddManagerDrawerOpen: boolean = false;
  @State addManagerDrawerWidth: number = 0;

  aboutToAppear() {
    // 初始化 UI 上下文
    let uiContext: UIContext = this.getUIContext() as UIContext;
    JhProgressHUD.initUIConfig(uiContext);

    // 获取用户凭证
    this.username = JhAESPreferencesUtils.getString("username") || '';
    this.token = JhAESPreferencesUtils.getString("token") || '';

    // 获取管理员列表
    this.fetchManagerList();
  }

  // 获取管理员列表
  private async fetchManagerList() {
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

      const res = await HttpUtils.get(APIs.pageManagerList, params);
      if (res.code === '0') {
        this.managerList = res.data.records;
        this.totalPages = Math.ceil(res.data.total / this.pageSize);
        // 计算页码范围
        this.calculatePageRange();
      } else {
        JhProgressHUD.showError('获取管理员列表失败');
      }
    } catch (error) {
      console.error('获取管理员列表失败:', error);
      JhProgressHUD.showError('获取管理员列表失败');
    }
  }

  // 处理搜索
  private handleSearch(value: string) {
    this.searchText = value;
    this.currentPage = 1; // 重置到第一页
    this.fetchManagerList();
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

  // 更新管理员状态
  private async updateManagerStatus(manager: Manager) {
    try {
      // 构建请求参数
      const params: object = Object({
        id: manager.id,
        username: manager.username,
        delFlag: manager.delFlag === 1 ? 0 : 1  // 切换状态
      });

      // 调用API
      const res = await HttpUtils.put(APIs.updateManager, params);

      if (res.code === '0') {
        JhProgressHUD.showSuccess(manager.delFlag === 1 ? '启用管理员成功' : '禁用管理员成功');

        // 刷新管理员列表
        this.fetchManagerList();
      } else {
        JhProgressHUD.showError(manager.delFlag === 1 ? '启用管理员失败' : '禁用管理员失败');
      }
    } catch (error) {
      console.error('更新管理员状态失败:', error);
      JhProgressHUD.showError(manager.delFlag === 1 ? '启用管理员失败' : '禁用管理员失败');
    }
  }

  // 分配权限
  private async assignPermission(manager: Manager) {
    try {
      // 显示确认对话框
      promptAction.showDialog({
        title: '分配',
        buttons: [
          {
            text: '取消',
            color: '#666666',
          } as DialogButtonOptions,
          {
            text: '确定',
            color: this.themeColor,
          } as DialogButtonOptions
        ],
      })
        .then(async (result) => {
          if (result.index === 1) {
            JhProgressHUD.showLoading('处理中...');

            // 构建请求参数
            const params: object = Object({
              id: manager.id,
              username: manager.username,
              isSuper: manager.isSuper === 1 ? 0 : 1  // 切换权限
            });

            // 调用API
            const res = await HttpUtils.put(APIs.updateManager, params);

            if (res.code === '0') {
              JhProgressHUD.showSuccess('权限分配成功');
              // 刷新管理员列表
              this.fetchManagerList();
            } else {
              JhProgressHUD.showError('权限分配失败');
            }
          }
        });
    } catch (error) {
      console.error('分配权限失败:', error);
      JhProgressHUD.showError('分配权限失败');
    }
  }

  // 显示分配抽屉
  private showAssignDrawer(manager: Manager) {
    // 设置当前管理员并打开抽屉
    this.currentManager = manager;
    this.isAssignDrawerOpen = true;
    this.assignDrawerWidth = 880; // 调整抽屉宽度
    console.info('AssignDrawer抽屉已打开', manager.username);
  }
  
  // 关闭分配抽屉
  private closeAssignDrawer() {
    animateTo({
      duration: 250,
      curve: Curve.EaseOut,
      delay: 0,
      onFinish: () => {
        this.isAssignDrawerOpen = false;
      }
    }, () => {
      this.assignDrawerWidth = 0;
    })
  }

  // 显示添加管理员抽屉
  private showAddManagerDrawer() {
    this.isAddManagerDrawerOpen = true;
    this.addManagerDrawerWidth = 880;
    console.info('AddManagerPage抽屉已打开');
  }
  
  // 关闭添加管理员抽屉
  private closeAddManagerDrawer() {
    animateTo({
      duration: 250,
      curve: Curve.EaseOut,
      delay: 0,
      onFinish: () => {
        this.isAddManagerDrawerOpen = false;
      }
    }, () => {
      this.addManagerDrawerWidth = 0;
    })
  }

  build() {
    Stack() {
      // 主内容区域
      Column() {
        // 标题
        Text('管理员列表')
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
              Search({ placeholder: '请输入管理员名称搜索', value: this.searchDisplayText })
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
                this.fetchManagerList();
              })

            // 查看管理员状态按钮
            Button(this.viewMode === 'all' ? '查看禁用管理员' :
              this.viewMode === 'disabled' ? '查看启用管理员' : '查看所有管理员')
              .height(36)
              .backgroundColor(this.viewMode === 'all' ? this.dangerColor :
                this.viewMode === 'disabled' ? this.successColor : this.themeColor)
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
                this.fetchManagerList();
              })

            // 添加管理员按钮
            Button('添加管理员')
              .height(36)
              .backgroundColor(this.themeColor)
              .fontColor(Color.White)
              .fontSize(14)
              .borderRadius(2)
              .onClick(() => this.showAddManagerDrawer())
          }
          .width('40%')
          .justifyContent(FlexAlign.End)
        }
        .width('100%')
        .margin({ bottom: 12, top: -8 })
        .justifyContent(FlexAlign.SpaceBetween)

        // 管理员列表
        Column() {
          // 表头
          Row() {
            Text('用户名')
              .width('15%')
              .fontSize(14)
              .fontColor(this.textColorSecondary)
              .textAlign(TextAlign.Center)
            Text('手机号')
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
              .width('20%')
              .fontSize(14)
              .fontColor(this.textColorSecondary)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .height(45)
          .padding({ left: 16, right: 16 })
          .backgroundColor(this.cardBgColor)

          List() {
            // 管理员数据
            ForEach(this.managerList, (manager: Manager) => {
              ListItem() {
                Row() {
                  Text(manager.username)
                    .width('15%')
                    .fontSize(14)
                    .fontColor(this.textColorSecondary)
                    .textAlign(TextAlign.Center)
                  Text(manager.phone || '-')
                    .width('20%')
                    .fontSize(14)
                    .fontColor(this.textColorSecondary)
                    .textAlign(TextAlign.Center)
                  Text(manager.mail || '-')
                    .width('20%')
                    .fontSize(14)
                    .fontColor(this.textColorSecondary)
                    .textAlign(TextAlign.Center)
                  Text(manager.delFlag === 1 ? '是' : '否')
                    .width('10%')
                    .fontSize(14)
                    .fontColor(manager.delFlag === 1 ? this.dangerColor : this.textColorSecondary)
                    .textAlign(TextAlign.Center)
                  Text(manager.createTime ? this.formatDate(manager.createTime) : '')
                    .width('15%')
                    .fontSize(14)
                    .fontColor(this.textColorSecondary)
                    .textAlign(TextAlign.Center)
                  
                  // 操作按钮
                  Row({ space: 8 }) {
                    // 分配用户按钮
                    Button('分配')
                      .height(32)
                      .backgroundColor(this.themeColor)
                      .fontColor(Color.White)
                      .fontSize(14)
                      .borderRadius(2)
                      .onClick(() => this.showAssignDrawer(manager))

                    // 禁用/启用按钮
                    Button(manager.delFlag === 1 ? '启用' : '禁用')
                      .height(32)
                      .backgroundColor(manager.delFlag === 1 ? this.themeColor : this.dangerColor)
                      .fontColor(Color.White)
                      .fontSize(14)
                      .borderRadius(2)
                      .onClick(() => {
                        promptAction.showDialog({
                          title: manager.delFlag === 1 ? '启用确认' : '禁用确认',
                          message: manager.delFlag === 1 ?
                            '确定要启用该管理员吗？\n' :
                            '确定要禁用该管理员吗？\n',
                          buttons: [
                            {
                              text: '取消',
                              color: '#666666',
                            } as DialogButtonOptions,
                            {
                              text: manager.delFlag === 1 ? '确定启用' : '确定禁用',
                              color: manager.delFlag === 1 ? this.themeColor : this.dangerColor,
                            } as DialogButtonOptions
                          ],
                        })
                          .then((result) => {
                            if (result.index === 1) {
                              // 调用更新API，传入管理员信息和状态
                              this.updateManagerStatus(manager);
                            }
                          })
                      })
                  }
                  .width('20%')
                  .justifyContent(FlexAlign.Center)
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
                this.fetchManagerList();
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
                  this.fetchManagerList();
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
                this.fetchManagerList();
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
                  this.fetchManagerList();
                  this.inputPage = '';
                } else {
                  JhProgressHUD.showText('请输入有效页码');
                }
              })
          }
          .layoutWeight(2)
          .justifyContent(FlexAlign.Center)

          // 总条数显示在右侧
          Text(`共 ${this.managerList.length} 条`)
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
      .zIndex(1)
      
      // 分配抽屉 (条件渲染)
      if (this.isAssignDrawerOpen || this.assignDrawerWidth > 0) {
        Stack() {
          // 右侧抽屉内容
          AssignDrawer({
            manager: this.currentManager,
            onCancel: () => {
              this.closeAssignDrawer();
            }
          })
          .width(this.assignDrawerWidth)
          .height('100%')
          .position({ x: '100%' })
          .translate({ x: this.isAssignDrawerOpen ? -this.assignDrawerWidth : 0 })
          .animation({
            duration: 250,
            curve: Curve.EaseOut
          })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(100)
      }

      // 添加管理员抽屉 (条件渲染)
      if (this.isAddManagerDrawerOpen || this.addManagerDrawerWidth > 0) {
        Stack() {
          // 右侧抽屉内容
          AddManagerPage({
            isDrawerOpening: this.isAddManagerDrawerOpen,
            drawerWidth: this.addManagerDrawerWidth,
            onSuccess: () => {
              // 刷新管理员列表
              this.fetchManagerList();
            }
          })
          .width(this.addManagerDrawerWidth)
          .height('100%')
          .position({ x: '100%' })
          .translate({ x: this.isAddManagerDrawerOpen ? -this.addManagerDrawerWidth : 0 })
          .animation({
            duration: 250,
            curve: Curve.EaseOut
          })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(100)
      }
    }
    .width('100%')
    .height('100%')
  }
} 