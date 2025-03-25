import { AssignItem, AssignedListResponse, Manager, AssignListParams, AssignUserParams } from '../../model/UserInterface';
import { HttpUtils } from '../../JhCommon/http/HttpUtils';
import { APIs } from '../../JhCommon/http/APIs';
import { JhProgressHUD } from '../../JhCommon/components/JhProgressHUD';

@Component
export struct AssignDrawer {
  // 属性可以从外部传入
  manager?: Manager;
  onCancel?: () => void;
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
  @State currentManager: Manager = new Manager();
  @State assignedList: Array<AssignItem> = [];
  @State unassignedList: Array<AssignItem> = [];
  @State isLoading: boolean = false;
  @State currentFilter: number = -1; // -1: 全部, 0: 仅用户, 1: 仅公司
  @State searchText: string = ''; // 搜索文本
  @State searchDisplayText: string = ''; // 搜索框显示文本

  // 分页状态
  @State assignedCurrentPage: number = 1;
  @State unassignedCurrentPage: number = 1;
  @State assignedPageSize: number = 10;
  @State unassignedPageSize: number = 10;
  @State assignedTotalPages: number = 1;
  @State unassignedTotalPages: number = 1;
  @State assignedInputPage: string = '';
  @State unassignedInputPage: string = '';

  // 添加初始化钩子
  aboutToAppear() {
    // 如果有传入manager，则使用传入的manager
    if (this.manager) {
      this.currentManager = this.manager;
      this.fetchAssignedList();
    }
  }

  // 获取已分配和未分配列表
  async fetchAssignedList() {
    try {
      this.isLoading = true;
      const params: object = Object({
        managerName: this.currentManager.username,
        userType: this.currentFilter === -1 ? undefined : this.currentFilter,
        assignedCurrent: this.assignedCurrentPage,
        assignedSize: this.assignedPageSize,
        unassignedCurrent: this.unassignedCurrentPage,
        unassignedSize: this.unassignedPageSize,
        likeUserName: this.searchText ? this.searchText : undefined
      });

      const res = await HttpUtils.post(APIs.getAssignedList, params);
      if (res.code === '0') {
        const data = res.data as AssignedListResponse;
        this.assignedList = data.assignedList || [];
        this.unassignedList = data.unAssignedList || [];
        // 更新总页数
        this.assignedTotalPages = Math.ceil((data.assignedTotal || 0) / this.assignedPageSize);
        this.unassignedTotalPages = Math.ceil((data.unassignedTotal || 0) / this.unassignedPageSize);
      } else {
        JhProgressHUD.showError('获取分配列表失败');
      }
    } catch (error) {
      console.error('获取分配列表失败:', error);
      JhProgressHUD.showError('获取分配列表失败');
    } finally {
      this.isLoading = false;
    }
  }

  // 切换筛选条件
  changeFilter(filter: number) {
    this.currentFilter = filter;
    this.fetchAssignedList();
  }

  // 分配用户/公司给管理员
  async assignToManager(item: AssignItem) {
    try {
      const params: AssignUserParams = {
        managerName: this.currentManager.username,
        username: item.username,
        userType: item.userType
      };

      const res = await HttpUtils.post(APIs.createManagerToUser, params);
      if (res.code === '0') {
        JhProgressHUD.showSuccess('分配成功');
        this.fetchAssignedList();
      } else {
        JhProgressHUD.showError('分配失败');
      }
    } catch (error) {
      console.error('分配失败:', error);
      JhProgressHUD.showError('分配失败');
    }
  }

  // 取消分配
  async cancelAssign(item: AssignItem) {
    try {
      const param: object = Object({
        managerName: item.managerName,
        username: item.username
      });

      const res = await HttpUtils.post(APIs.deleteManagerToUser, param);
      if (res.code === '0') {
        JhProgressHUD.showSuccess('取消分配成功');
        this.fetchAssignedList();
      } else {
        JhProgressHUD.showError('取消分配失败');
      }
    } catch (error) {
      console.error('取消分配失败:', error);
      JhProgressHUD.showError('取消分配失败');
    }
  }

  getTypeText(type: number): string {
    return type === 0 ? '个人用户' : '公司';
  }

  // 处理搜索
  private handleSearch(value: string) {
    this.searchText = value;
    this.assignedCurrentPage = 1; // 重置到第一页
    this.unassignedCurrentPage = 1; // 重置到第一页
    this.fetchAssignedList();
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('分配用户与公司')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.textColor)

        Blank()

        Button() {
          Text('×')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.textColorSecondary)
        }
        .backgroundColor(Color.Transparent)
        .width(32)
        .height(32)
        .onClick(() => {
          if (this.onCancel) {
            this.onCancel();
          }
        })
      }
      .width('100%')
      .height(36)
      .padding({ left: 24, right: 16 })
      .borderRadius({ topLeft: 8, topRight: 0 })
      .borderWidth({ bottom: 1 })
      .borderColor(this.borderColorValue)
      .backgroundColor(this.themeColorLight)

      // 管理员信息
      Row() {
        Text(`管理员名称: ${this.currentManager.username || ''}`)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.textColor)
        
        Blank()
        
        // 搜索框
        Row() {
          Search({ placeholder: '请输入用户名/公司名搜索', value: this.searchDisplayText })
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
        .width(300)
        .margin({ right: 16 })
        
        Row() {
          Button('全部')
            .width(80)
            .height(28)
            .backgroundColor(this.currentFilter === -1 ? this.themeColor : Color.White)
            .fontColor(this.currentFilter === -1 ? Color.White : this.textColorSecondary)
            .borderColor(this.borderColorValue)
            .borderWidth(1)
            .fontSize(12)
            .borderRadius(2)
            .onClick(() => this.changeFilter(-1))
          
          Button('仅用户')
            .width(80)
            .height(28)
            .backgroundColor(this.currentFilter === 0 ? this.themeColor : Color.White)
            .fontColor(this.currentFilter === 0 ? Color.White : this.textColorSecondary)
            .borderColor(this.borderColorValue)
            .borderWidth(1)
            .fontSize(12)
            .borderRadius(2)
            .margin({ left: 8 })
            .onClick(() => this.changeFilter(0))
          
          Button('仅公司')
            .width(80)
            .height(28)
            .backgroundColor(this.currentFilter === 1 ? this.themeColor : Color.White)
            .fontColor(this.currentFilter === 1 ? Color.White : this.textColorSecondary)
            .borderColor(this.borderColorValue)
            .borderWidth(1)
            .fontSize(12)
            .borderRadius(2)
            .margin({ left: 8 })
            .onClick(() => this.changeFilter(1))
        }
      }
      .width('100%')
      .padding({
        left: 15,
        right: 24,
        top: 16,
        bottom: 16
      })
      .backgroundColor(this.themeColorLight)
      .justifyContent(FlexAlign.SpaceBetween)

      // 内容区域 - 左右分栏
      Row() {
        if (this.isLoading) {
          LoadingProgress()
            .width(50)
            .height(50)
            .color(this.themeColor)
            .layoutWeight(1)
        } else {
          // 左侧 - 已分配列表
          Column() {
            // 列表标题
            Row() {
              Text('已分配列表')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.textColor)
            }
            .width('100%')
            .padding({
              left: 16,
              right: 16,
              top: 12,
              bottom: 12
            })
            .backgroundColor(this.themeColorLight)

            // 列表表头
            Row() {
              Text('用户名/公司名')
                .width('40%')
                .fontSize(14)
                .fontColor(this.textColorSecondary)
                .textAlign(TextAlign.Center)
                .padding({ left: 16, right: 16 })

              Text('类型')
                .width('30%')
                .fontSize(14)
                .fontColor(this.textColorSecondary)
                .textAlign(TextAlign.Center)
                .padding({ left: 8, right: 8 })

              Text('操作')
                .width('30%')
                .fontSize(14)
                .fontColor(this.textColorSecondary)
                .textAlign(TextAlign.Center)
                .padding({ left: 8, right: 8 })
            }
            .width('100%')
            .height(40)
            .backgroundColor(this.cardBgColor)
            .borderWidth({ bottom: 1 })
            .borderColor(this.borderColorValue)

            // 已分配列表
            List() {
              ForEach(this.assignedList, (item: AssignItem) => {
                ListItem() {
                  this.buildAssignedItem(item)
                }
              })
            }
            .width('100%')
            .layoutWeight(1)
            .divider({ strokeWidth: 1, color: this.borderColorValue })
            .backgroundColor(Color.White)
          }
          .width('50%')
          .height('100%')
          .borderWidth({ right: 1 })
          .borderColor(this.borderColorValue)

          // 右侧 - 未分配列表
          Column() {
            // 列表标题
            Row() {
              Text('未分配列表')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.textColor)
            }
            .width('100%')
            .padding({
              left: 16,
              right: 16,
              top: 12,
              bottom: 12
            })
            .backgroundColor(this.themeColorLight)

            // 列表表头
            Row() {
              Text('用户名/公司名')
                .width('40%')
                .fontSize(14)
                .fontColor(this.textColorSecondary)
                .textAlign(TextAlign.Center)
                .padding({ left: 16, right: 16 })

              Text('类型')
                .width('30%')
                .fontSize(14)
                .fontColor(this.textColorSecondary)
                .textAlign(TextAlign.Center)
                .padding({ left: 8, right: 8 })

              Text('操作')
                .width('30%')
                .fontSize(14)
                .fontColor(this.textColorSecondary)
                .textAlign(TextAlign.Center)
                .padding({ left: 8, right: 8 })
            }
            .width('100%')
            .height(40)
            .backgroundColor(this.cardBgColor)
            .borderWidth({ bottom: 1 })
            .borderColor(this.borderColorValue)

            // 未分配列表
            List() {
              ForEach(this.unassignedList, (item: AssignItem) => {
                ListItem() {
                  this.buildUnassignedItem(item)
                }
              })
            }
            .width('100%')
            .layoutWeight(1)
            .divider({ strokeWidth: 1, color: this.borderColorValue })
            .backgroundColor(Color.White)
          }
          .width('50%')
          .height('100%')
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 8, bottomLeft: 8 })
    .id('assignDrawer')
  }

  @Builder
  buildAssignedItem(item: AssignItem) {
    Row() {
      Text(item.username)
        .width('40%')
        .fontSize(14)
        .fontColor(this.textColorSecondary)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
        .textAlign(TextAlign.Center)
        .padding({ left: 16, right: 16 })

      Text(this.getTypeText(item.userType))
        .width('30%')
        .fontSize(14)
        .fontColor(this.textColorSecondary)
        .textAlign(TextAlign.Center)
        .padding({ left: 8, right: 8 })

      Row() {
        Button('移除')
          .width(80)
          .height(32)
          .backgroundColor(Color.White)
          .borderColor(this.dangerColor)
          .borderWidth(1)
          .fontColor(this.dangerColor)
          .fontSize(14)
          .borderRadius(2)
          .onClick(() => {
            this.cancelAssign(item);
          })
      }
      .width('30%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height(48)
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  buildUnassignedItem(item: AssignItem) {
    Row() {
      Text(item.username)
        .width('40%')
        .fontSize(14)
        .fontColor(this.textColorSecondary)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
        .textAlign(TextAlign.Center)
        .padding({ left: 16, right: 16 })

      Text(this.getTypeText(item.userType))
        .width('30%')
        .fontSize(14)
        .fontColor(this.textColorSecondary)
        .textAlign(TextAlign.Center)
        .padding({ left: 8, right: 8 })

      Row() {
        Button('分配')
          .width(80)
          .height(32)
          .backgroundColor(this.themeColor)
          .fontColor(Color.White)
          .fontSize(14)
          .borderRadius(2)
          .onClick(() => {
            this.assignToManager(item);
          })
      }
      .width('30%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height(48)
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceBetween)
  }
} 