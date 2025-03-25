///  APIs.ets
///
///  Created by iotjin on 2024/08/08.
///  description: api管理

export class APIs {
  // url 前缀
  static readonly apiPrefix: string = '172.18.128.1:8003'

  //=====================用户管理===========================
  static readonly pageUserList: string = '/api/short-link/admin/v1/manager-to-user/pageUserList'
  static readonly updateUser: string = '/api/short-link/admin/v1/user'

  //=====================管理员管理===========================
  static readonly managerLogin: string = '/api/short-link/admin/v1/manager/login'
  static readonly checkLogin: string = '/api/short-link/admin/v1/manager/check-login'
  static readonly getManagerByUsername: string = '/api/short-link/admin/v1/manager/'
  static readonly pageManagerList: string = '/api/short-link/admin/v1/manager/page'
  static readonly updateManager: string = '/api/short-link/admin/v1/manager'
  static readonly createManager: string = '/api/short-link/admin/v1/manager'

  //=====================管理员用户分配===========================
  static readonly getAssignedList: string = '/api/short-link/admin/v1/manager-to-user/getAssignedList'
  static readonly createManagerToUser: string = '/api/short-link/admin/v1/manager-to-user'
  static readonly deleteManagerToUser: string = '/api/short-link/admin/v1/manager-to-user/delete'
  static readonly assignedUsers: string = '/api/short-link/admin/v1/manager/assign/assigned-users'
  static readonly unassignedUsers: string = '/api/short-link/admin/v1/manager/assign/unassigned-users'
  static readonly assignUser: string = '/api/short-link/admin/v1/manager/assign/assign-user'
  static readonly getManagerShortLink: string = '/api/short-link/v1/manager-to-user/getManagerShortLink'
  static readonly listByManagerName: string = '/api/short-link/admin/v1/manager-to-user/manager/'

  //=====================短链接状态===========================
  // 访问单个短链接指定时间内监控数据
  static readonly shortLinkStats: string = '/api/short-link/admin/v1/stats';

  // 访问分组短链接指定时间内监控数据
  static readonly groupShortLinkStats: string = '/api/short-link/v1/stats/group';

  // 访问单个短链接指定时间内访问记录监控数据
  static readonly shortLinkStatsAccessRecord: string = '/api/short-link/v1/stats/access-record';

  // 访问分组短链接指定时间内访问记录监控数据
  static readonly groupShortLinkStatsAccessRecord: string = '/api/short-link/v1/stats/access-record/group';




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