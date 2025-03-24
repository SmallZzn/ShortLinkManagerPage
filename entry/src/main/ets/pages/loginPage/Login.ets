import router from '@ohos.router';
import { JhProgressHUD } from '../../JhCommon/components/JhProgressHUD';
import { HttpUtils } from '../../JhCommon/http/HttpUtils';
import { APIs } from '../../JhCommon/http/APIs';
import { JhAESPreferencesUtils } from '../../JhCommon/utils/JhPreferencesUtils';

@Entry
@Component
struct Login {
  @State username: string = '';
  @State password: string = '';
  @State isShowPassword: boolean = false;
  @State isLoading: boolean = false;

  aboutToAppear() {
    // 初始化UI上下文
    let uiContext: UIContext = this.getUIContext() as UIContext;
    JhProgressHUD.initUIConfig(uiContext);
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 背景图层
      Image($r('app.media.LoginBackground'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .blur(8)// 添加虚化效果
        .opacity(0.8) // 降低不透明度使其更柔和

      // 主要内容
      Column() {
        // 顶部标题
        Text('短链接服务后台管理')
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .margin({ bottom: 60 })

        // 登录容器
        Column() {
          // 左侧区域 - 登录表单
          Column() {
            Text('欢迎回来')
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 8 })
              .fontColor('#333333')

            Text('请登录您的账号')
              .fontSize(16)
              .fontColor('#666666')
              .margin({ bottom: 40 })

            // 用户名输入框
            Column() {
              TextInput({ text: this.username, placeholder: '请输入用户名' })
                .width('100%')
                .height(45)
                .fontSize(16)
                .placeholderColor('rgba(0, 0, 0, 0.4)')
                .padding({ left: 16, right: 16 })
                .backgroundColor('rgba(255, 255, 255, 0.8)')
                .borderRadius(8)
                .border({ width: 1, color: 'rgba(0, 0, 0, 0.1)' })
                .onChange((value: string) => {
                  this.username = value;
                })
            }
            .margin({ bottom: 15 })
            .width('100%')

            // 密码输入框
            Column() {
              TextInput({ text: this.password, placeholder: '请输入密码' })
                .width('100%')
                .height(45)
                .fontSize(16)
                .placeholderColor('rgba(0, 0, 0, 0.4)')
                .padding({ left: 16, right: 16 })
                .backgroundColor('rgba(255, 255, 255, 0.8)')
                .borderRadius(8)
                .border({ width: 1, color: 'rgba(0, 0, 0, 0.1)' })
                .type(this.isShowPassword ? InputType.Normal : InputType.Password)
                .onChange((value: string) => {
                  this.password = value;
                })
            }
            .margin({ bottom: 40 })
            .width('100%')

            // 登录按钮
            Button('登 录', { stateEffect: true })
              .width('100%')
              .height(50)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
              .backgroundColor('#007AFF')
              .borderRadius(25)
              .shadow({ radius: 8, color: 'rgba(0, 122, 255, 0.3)', offsetY: 4 })
              .onClick(() => this.handleLogin())
              .enabled(!this.isLoading)
          }
          .width('80%')
          .alignItems(HorizontalAlign.Start)
          .padding(40)
          .backgroundColor('rgba(255, 255, 255, 0.95)') // 半透明白色背景
          .borderRadius(16)
          .backdropBlur(24) // 玻璃拟态效果
          .shadow({
            radius: 24,
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: 4
          })
        }
        .width('50%')
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
    }
    .width('100%')
    .height('111%')
    .margin({ top: -39 }) // 调整顶部边距
  }

  // 处理登录
  async handleLogin() {
    // 校验输入
    if (!this.username || !this.password) {
      JhProgressHUD.showToast('请输入用户名和密码');
      return;
    }

    try {
      this.isLoading = true;
      // 显示加载中
      JhProgressHUD.showLoading('登录中...');

      // 调用登录接口
      const params: object = Object({
        username: this.username,
        password: this.password
      });

      const res = await HttpUtils.post(APIs.managerLogin, params);

      // 登录成功
      if (res.code === '0' && res.data) {
        // 保存登录信息
        JhAESPreferencesUtils.saveString('username', this.username);
        JhAESPreferencesUtils.saveString('token', res.data.token);

        // 跳转到主页
        router.replaceUrl({
          url: 'pages/ManagementMain'
        });

        JhProgressHUD.showSuccess('登录成功');
      } else {
        // 登录失败
        JhProgressHUD.showError(res.message || '登录失败，请检查用户名和密码');
      }
    } catch (error) {
      console.error('登录失败:', error);
      JhProgressHUD.showError('登录失败，请稍后重试');
    } finally {
      this.isLoading = false;
      JhProgressHUD.hide();
    }
  }
} 