import { JhProgressHUD } from "../../JhCommon/components/JhProgressHUD";
import { APIs } from "../../JhCommon/http/APIs";
import { HttpUtils } from "../../JhCommon/http/HttpUtils";

// 管理员信息接口
interface ManagerInfo {
  username: string;
  password?: string;
  mail?: string;
  phone?: string;
  isSuper?: number; // 是否超级管理员: 0不是, 1是
}

@Component
export struct AddManagerPage {
  @Link isDrawerOpening: boolean;
  @Link drawerWidth: number;
  @State managerInfo: ManagerInfo = { username: '' };
  @State isLoading: boolean = false;
  // 添加刷新列表的回调函数
  onSuccess?: () => void;
  // 主题颜色常量
  readonly themeColor: string = '#4080FF'; // 主题蓝色
  readonly themeColorLight: string = '#F2F3F5'; // 浅色背景
  readonly pageBgColor: string = '#FFFFFF'; // 页面背景色
  readonly textColor: string = '#1D2129'; // 主要文字颜色
  readonly textColorSecondary: string = '#86909C'; // 次要文字颜色
  readonly themeBorderColor: string = '#E5E6EB'; // 边框颜色

  // 重置表单
  resetForm() {
    this.managerInfo = {
      username: '',
      password: '',
      mail: '',
      phone: '',
      isSuper: 0
    };
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

  // 提交添加管理员
  async submitAddManager() {
    // 表单验证
    if (!this.managerInfo.username) {
      JhProgressHUD.showError('用户名不能为空');
      return;
    }

    if (!this.managerInfo.password) {
      JhProgressHUD.showError('密码不能为空');
      return;
    }

    if (this.managerInfo.password.length < 8) {
      JhProgressHUD.showError('密码长度不能少于8位');
      return;
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

      // 构建请求参数
      const params: object = Object({
        username: this.managerInfo.username,
        password: this.managerInfo.password,
        mail: this.managerInfo.mail || undefined,
        phone: this.managerInfo.phone || undefined,
        isSuper: 0,
        delFlay: 0
      });

      // 发送添加请求
      const res = await HttpUtils.post(APIs.createManager, params);

      if (res.code === '0') {
        this.resetForm();
        this.closeDrawer();
        // 调用刷新列表的回调函数
        if (this.onSuccess) {
          this.onSuccess();
        }
      } else {
        JhProgressHUD.showError(res.message || '添加失败');
      }
    } catch (error) {
      console.error('添加管理员失败:', error);
      JhProgressHUD.showError('添加管理员失败');
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('添加管理员')
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
          if (this.managerInfo.username || this.managerInfo.password || this.managerInfo.phone ||
          this.managerInfo.mail) {
            AlertDialog.show({
              title: '提示',
              message: '您有未保存的内容，确定要关闭吗？',
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

            TextInput({ text: this.managerInfo.username, placeholder: '请输入用户名' })
              .width('80%')
              .height(40)
              .borderRadius(4)
              .backgroundColor(Color.White)
              .border({ width: 1, color: this.themeBorderColor })
              .placeholderColor('#C9CDD4')
              .onChange((value: string) => {
                this.managerInfo.username = value;
              })
          }
          .width('100%')
          .margin({ top: 0, bottom: 16 })
          .alignItems(VerticalAlign.Center)

          // 密码
          Row() {
            Text('密码')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.textColor)
              .width('20%')

            TextInput({ placeholder: '请输入密码' })
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
              .backgroundColor(Color.White)
              .border({ width: 1, color: this.themeBorderColor })
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
              .backgroundColor(Color.White)
              .border({ width: 1, color: this.themeBorderColor })
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
        Button('取消')
          .width('30%')
          .height(36)
          .fontSize(14)
          .fontColor(this.textColor)
          .backgroundColor(Color.White)
          .border({ width: 1, color: this.themeBorderColor })
          .borderRadius(4)
          .onClick(() => this.closeDrawer())

        Button('确定')
          .width('30%')
          .height(36)
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor(this.themeColor)
          .borderRadius(4)
          .onClick(() => this.submitAddManager())
      }
      .width('100%')
      .padding({
        left: 24,
        right: 24,
        top: 24,
        bottom: 40
      })
      .justifyContent(FlexAlign.SpaceEvenly)
      .backgroundColor(Color.White)
      .border({ width: { top: 1 }, color: this.themeBorderColor })
    }
    .width(this.drawerWidth)
    .height('100%')
    .backgroundColor(Color.White)
    .position({ x: 0 })
    .translate({ x: this.isDrawerOpening ? 0 : this.drawerWidth })
    .animation({
      duration: 250,
      curve: Curve.EaseOut
    })
  }
}
