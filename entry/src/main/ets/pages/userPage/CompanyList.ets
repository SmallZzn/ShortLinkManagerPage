import { HttpUtils } from '../../JhCommon/http/HttpUtils';
import { APIs } from '../../JhCommon/http/APIs';
import { JhAESPreferencesUtils } from '../../JhCommon/utils/JhPreferencesUtils';
import { JhProgressHUD } from '../../JhCommon/components/JhProgressHUD';

// 管理员信息接口
interface ManagerInfo {
  username: string;
  realName?: string;
  oldPassword?: string;
  password?: string;
  confirmPassword?: string;
  mail?: string;
  phone?: string;
  isSuper?: number; // 是否超级管理员: 0不是, 1是
}

@Component
export struct ManagerInfoPopup {
  @Link isDrawerOpening: boolean;
  @Link drawerWidth: number;
  @State managerInfo: ManagerInfo = { username: '' };
  @State oldPassword: string = '';
  @State confirmPassword: string = '';
  @State isLoading: boolean = false;
  @State isEditing: boolean = false; // 恢复内部编辑状态
  // 主题颜色常量
  readonly themeColor: string = '#4080FF'; // 主题蓝色
  readonly themeColorLight: string = '#F2F3F5'; // 浅色背景
  readonly pageBgColor: string = '#FFFFFF'; // 页面背景色
  readonly textColor: string = '#1D2129'; // 主要文字颜色
  readonly textColorSecondary: string = '#86909C'; // 次要文字颜色
  readonly themeBorderColor: string = '#E5E6EB'; // 边框颜色
  // 用于处理回调
  @State onSuccessCallback: boolean = false;

  aboutToAppear() {
    // 获取当前登录用户名
    const username = JhAESPreferencesUtils.getString('username') || '';
    if (username) {
      this.managerInfo.username = username;
      this.fetchManagerInfo();
    }
    console.info('ManagerInfoPopup aboutToAppear，抽屉状态:', this.isDrawerOpening, '宽度:', this.drawerWidth);
  }

  onPropertyChanged(propName: string) {
    if (propName === 'isDrawerOpening' || propName === 'drawerWidth') {
      console.info(`属性 ${propName} 变化为: ${propName === 'isDrawerOpening' ? this.isDrawerOpening :
      this.drawerWidth}`);
    }
  }

  // 获取管理员信息
  async fetchManagerInfo() {
    try {
      this.isLoading = true;
      JhProgressHUD.showLoadingText('加载中...');

      // 发送请求获取管理员信息
      const res =
        await HttpUtils.get(`${APIs.getManagerByUsername}${encodeURIComponent(this.managerInfo.username)}`, {});

      console.info('获取管理员信息响应:', JSON.stringify(res));

      if (res.code === '0' && res.data) {
        // 设置管理员信息
        this.managerInfo = {
          username: res.data.username || '',
          realName: res.data.realName || '',
          password: res.data.password || '',
          mail: res.data.mail || '',
          phone: res.data.phone || '',
          isSuper: res.data.isSuper || 0
        };

        console.info('设置后的管理员信息:', JSON.stringify(this.managerInfo));

        JhProgressHUD.hide();
      } else {
        JhProgressHUD.showError('获取管理员信息失败');
      }
    } catch (error) {
      console.error('获取管理员信息失败:', error);
      JhProgressHUD.showError('获取管理员信息失败');
    } finally {
      this.isLoading = false;
    }
  }

  // 提交更新管理员信息
  async updateManagerInfo() {
    // 表单验证
    if (this.isEditing) {
      // 验证必填字段
      if (!this.managerInfo.username) {
        JhProgressHUD.showError('用户名不能为空');
        return;
      }

      // 验证密码
      const isPasswordChanged = !!(this.oldPassword || this.managerInfo.password || this.confirmPassword);

      if (isPasswordChanged) {
        // 检查旧密码
        if (!this.oldPassword) {
          JhProgressHUD.showError('请输入旧密码');
          return;
        }

        // 检查新密码
        if (!this.managerInfo.password) {
          JhProgressHUD.showError('请输入新密码');
          return;
        }

        if (this.managerInfo.password != this.oldPassword) {
          JhProgressHUD.showError('旧密码不正确');
          return;
        }

        if (this.managerInfo.password.length < 8) {
          JhProgressHUD.showError('密码长度不能少于8位');
          return;
        }

        if (this.managerInfo.password !== this.confirmPassword) {
          JhProgressHUD.showError('两次输入的密码不一致');
          return;
        }
      }

      // 验证手机号
      if (this.managerInfo.phone && !/^1[3-9]\d{9}$/.test(this.managerInfo.phone)) {
        JhProgressHUD.showError('请输入正确的手机号');
        return;
      }

      // 验证邮箱
      if (this.managerInfo.mail && !/^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/.test(this.managerInfo.mail)) {
        JhProgressHUD.showError('请输入正确的邮箱');
        return;
      }

      try {
        this.isLoading = true;
        JhProgressHUD.showLoadingText('提交中...');

        // 构建请求参数
        const params: object = Object({
          username: this.managerInfo.username,
          mail: this.managerInfo.mail || undefined,
          phone: this.managerInfo.phone || undefined,
          realName: this.managerInfo.realName || undefined
        });

        // 如果要修改密码，添加密码参数
        if (isPasswordChanged) {
          params['password'] = this.managerInfo.password;
        }

        // 发送更新请求 - 假设使用相同的API更新管理员信息
        const res = await HttpUtils.put(APIs.updateUser, params);

        if (res.code === '0') {
          JhProgressHUD.showSuccess('更新成功');
          this.isEditing = false;
          this.fetchManagerInfo(); // 刷新管理员信息
          this.handleSuccess(); // 触发成功回调
        } else {
          JhProgressHUD.showError(res.message || '更新失败');
        }
      } catch (error) {
        console.error('更新管理员信息失败:', error);
        JhProgressHUD.showError('更新管理员信息失败');
      } finally {
        this.isLoading = false;
      }
    } else {
      // 进入编辑模式
      this.isEditing = true;
      this.oldPassword = '';
      this.confirmPassword = '';
    }
  }

  // 取消编辑
  cancelEdit() {
    this.isEditing = false;
    this.oldPassword = '';
    this.confirmPassword = '';
    this.fetchManagerInfo(); // 重新获取管理员信息
  }

  // 关闭抽屉
  closeDrawer() {
    console.info('closeDrawer被调用，准备关闭抽屉');
    animateTo({
      duration: 250,
      curve: Curve.EaseOut,
      delay: 0,
      onFinish: () => {
        this.isDrawerOpening = false;
        console.info('关闭动画完成');
      }
    }, () => {
      this.drawerWidth = 0;
    })
  }

  // 触发成功回调
  handleSuccess() {
    this.onSuccessCallback = !this.onSuccessCallback;
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('修改信息')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.textColor)

        Blank()

        Button() {
          Text('×')
            .fontSize(24)
            .fontColor(this.textColorSecondary)
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          if (this.isEditing) {
            AlertDialog.show({
              title: '提示',
              message: '您有未保存的编辑内容，确定要关闭吗？',
              primaryButton: {
                value: '取消',
                action: () => {
                }
              },
              secondaryButton: {
                value: '确定',
                action: () => {
                  this.closeDrawer();
                }
              }
            });
          } else {
            this.closeDrawer();
          }
        })
      }
      .width('100%')
      .height(80)
      .padding({
        left: 24,
        right: 24,
        top: 30,
        bottom: 24
      })
      .border({ width: { bottom: 1 }, color: this.themeBorderColor })

      // 管理员信息表单
      Scroll() {
        Column({ space: 10 }) {
          // 用户名
          Row() {
            Text('用户名称')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.textColor)
              .width('20%')

            TextInput({ text: this.managerInfo.username })
              .width('80%')
              .height(40)
              .borderRadius(4)
              .backgroundColor(this.themeColorLight)
              .enabled(false) // 用户名不可修改
          }
          .width('100%')
          .margin({ top: 0, bottom: 16 })
          .alignItems(VerticalAlign.Center)
          
          // 管理员权限级别 (只显示不可编辑)
          Row() {
            Text('权限级别')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.textColor)
              .width('20%')

            Row() {
              Text(this.managerInfo.isSuper === 1 ? '超级管理员' : '普通管理员')
                .fontSize(14)
                .fontColor(this.textColor)
            }
            .width('80%')
            .height(40)
            .backgroundColor(this.themeColorLight)
            .borderRadius(4)
            .padding({ left: 12, right: 12 })
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .margin({ bottom: 16 })
          .alignItems(VerticalAlign.Center)

          // 密码相关字段（编辑状态下显示）
          if (this.isEditing) {
            // 旧密码
            Row() {
              Text('旧密码')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.textColor)
                .width('20%')

              TextInput({ placeholder: '请输入旧密码（不修改密码请留空）' })
                .width('80%')
                .height(40)
                .borderRadius(4)
                .backgroundColor(Color.White)
                .border({ width: 1, color: this.themeBorderColor })
                .type(InputType.Password)
                .placeholderColor('#C9CDD4')
                .onChange((value: string) => {
                  this.oldPassword = value;
                })
            }
            .width('100%')
            .margin({ bottom: 16 })
            .alignItems(VerticalAlign.Center)

            // 新密码
            Row() {
              Text('新密码')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.textColor)
                .width('20%')

              TextInput({ placeholder: '请输入新密码（不修改请留空）' })
                .width('80%')
                .height(40)
                .borderRadius(4)
                .backgroundColor(Color.White)
                .border({ width: 1, color: this.themeBorderColor })
                .type(InputType.Password)
                .placeholderColor('#C9CDD4')
                .onChange((value: string) => {
                  this.managerInfo.password = value;
                })
            }
            .width('100%')
            .margin({ bottom: 16 })
            .alignItems(VerticalAlign.Center)

            // 确认密码
            Row() {
              Text('确认新密码')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.textColor)
                .width('20%')

              TextInput({ placeholder: '请再次输入新密码' })
                .width('80%')
                .height(40)
                .borderRadius(4)
                .backgroundColor(Color.White)
                .border({ width: 1, color: this.themeBorderColor })
                .type(InputType.Password)
                .placeholderColor('#C9CDD4')
                .onChange((value: string) => {
                  this.confirmPassword = value;
                })
            }
            .width('100%')
            .margin({ bottom: 16 })
            .alignItems(VerticalAlign.Center)
          }

          // 手机号
          Row() {
            Text('手机号码')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.textColor)
              .width('20%')

            TextInput({ text: this.managerInfo.phone, placeholder: '请输入手机号码' })
              .width('80%')
              .height(40)
              .borderRadius(4)
              .backgroundColor(this.isEditing ? Color.White : this.themeColorLight)
              .border({ width: this.isEditing ? 1 : 0, color: this.themeBorderColor })
              .enabled(this.isEditing)
              .placeholderColor('#C9CDD4')
              .onChange((value: string) => {
                this.managerInfo.phone = value;
              })
          }
          .width('100%')
          .margin({ bottom: 16 })
          .alignItems(VerticalAlign.Center)

          // 邮箱
          Row() {
            Text('邮箱')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.textColor)
              .width('20%')

            TextInput({ text: this.managerInfo.mail, placeholder: '请输入邮箱' })
              .width('80%')
              .height(40)
              .borderRadius(4)
              .backgroundColor(this.isEditing ? Color.White : this.themeColorLight)
              .border({ width: this.isEditing ? 1 : 0, color: this.themeBorderColor })
              .enabled(this.isEditing)
              .placeholderColor('#C9CDD4')
              .onChange((value: string) => {
                this.managerInfo.mail = value;
              })
          }
          .width('100%')
          .margin({ bottom: 16 })
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .padding({ left: 24, right: 24, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .padding({ top: 20 })

      // 底部按钮区域
      Row() {
        if (this.isEditing) {
          // 编辑状态：显示取消和保存按钮
          Button('取消')
            .width('30%')
            .height(36)
            .fontSize(14)
            .fontColor(this.textColor)
            .backgroundColor(Color.White)
            .border({ width: 1, color: this.themeBorderColor })
            .borderRadius(4)
            .onClick(() => this.cancelEdit())

          Button('保存')
            .width('30%')
            .height(36)
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor(this.themeColor)
            .borderRadius(4)
            .onClick(() => this.updateManagerInfo())
        } else {
          // 查看状态：显示编辑按钮
          Button('编辑')
            .width('30%')
            .height(36)
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor(this.themeColor)
            .borderRadius(4)
            .onClick(() => this.updateManagerInfo())
        }
      }
      .width('100%')
      .padding({
        left: 24,
        right: 24,
        top: 24,
        bottom: 40
      })
      .justifyContent(this.isEditing ? FlexAlign.SpaceEvenly : FlexAlign.Center)
      .backgroundColor(Color.White)
      .border({ width: { top: 1 }, color: this.themeBorderColor })
    }
    .width(this.drawerWidth)
    .backgroundColor(Color.White)
    .position({ x: 0 })
    .translate({ x: this.isDrawerOpening ? 0 : -this.drawerWidth })
    .animation({
      duration: 250,
      curve: Curve.EaseOut
    })
  }
} 