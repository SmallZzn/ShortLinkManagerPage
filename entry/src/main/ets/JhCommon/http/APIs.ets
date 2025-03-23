///  APIs.ets
///
///  Created by iotjin on 2024/08/08.
///  description: api管理

export class APIs {
  // url 前缀
  static readonly apiPrefix: string = '172.19.64.1:8003'

  //=====================用户管理===========================
  static readonly pageUserList: string = '/api/short-link/admin/v1/user/pageUserList'
  static readonly updateUser: string = '/api/short-link/admin/v1/user'

  

  //=====================其它=============================
  /// 刷新token
  static readonly refreshToken: string = '/mock/refreshToken'
  /// 获取分页数据
  static readonly getPage: string = '/mock/pages'
  /// 获取分页分组数据
  static readonly getGroupPage: string = '/mock/groupPages'
  /// 获取固定数据
  static readonly getSimpleDictList: string = '/mock/simpleDictList'
  /// 获取固定数据
  static readonly getSimpleDict: string = '/mock/dict'
  /// 微信朋友圈
  static readonly getFriendsCircleList: string = '/mock/wx/moments'

}