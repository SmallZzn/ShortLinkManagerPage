import UIAbility from '@ohos.app.ability.UIAbility';
import common from '@ohos.app.ability.common';

/**
 * App 工具类
 */
export class AppUtil {
  private static instance: AppUtil;
  private static uiAbility: UIAbility;

  private constructor() {
    // 私有构造函数
  }

  /**
   * 初始化
   * @param ability UIAbility实例
   */
  public static init(ability: UIAbility): void {
    AppUtil.uiAbility = ability;
  }

  /**
   * 获取 UIAbility 实例
   */
  public static getUIAbility(): UIAbility {
    return AppUtil.uiAbility;
  }

  /**
   * 获取 Context
   */
  public static getContext(): common.UIAbilityContext {
    return AppUtil.uiAbility?.context;
  }
} 