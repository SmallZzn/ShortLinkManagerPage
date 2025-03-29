///  APIs.ets
///
///  Created by iotjin on 2024/08/08.
///  description: api管理

export class APIs {
  // url 前缀
  static readonly apiPrefix: string = '172.24.192.1:8003'
  //=====================用户管理===========================
  static readonly pageUserList: string = '/short-link/admin/v1/manager-to-user/pageUserList'
  static readonly updateUser: string = '/short-link/admin/v1/user'
  //=====================管理员管理===========================
  static readonly managerLogin: string = '/short-link/admin/v1/manager/login'
  static readonly checkLogin: string = '/short-link/admin/v1/manager/check-login'
  static readonly getManagerByUsername: string = '/short-link/admin/v1/manager/'
  static readonly pageManagerList: string = '/short-link/admin/v1/manager/page'
  static readonly updateManager: string = '/short-link/admin/v1/manager'
  static readonly createManager: string = '/short-link/admin/v1/manager'
  //=====================管理员用户分配===========================
  static readonly getAssignedList: string = '/short-link/admin/v1/manager-to-user/getAssignedList'
  static readonly createManagerToUser: string = '/short-link/admin/v1/manager-to-user'
  static readonly deleteManagerToUser: string = '/short-link/admin/v1/manager-to-user/delete'
  static readonly assignedUsers: string = '/short-link/admin/v1/manager/assign/assigned-users'
  static readonly unassignedUsers: string = '/short-link/admin/v1/manager/assign/unassigned-users'
  static readonly assignUser: string = '/short-link/admin/v1/manager/assign/assign-user'
  static readonly getManagerShortLink: string = '/short-link/v1/manager-to-user/getManagerShortLink'
  static readonly listByManagerName: string = '/short-link/admin/v1/manager-to-user/manager/'
  //=====================短链接状态===========================
  // 访问单个短链接指定时间内监控数据
  static readonly shortLinkStats: string = '/short-link/admin/v1/stats';
  // 访问分组短链接指定时间内监控数据
  static readonly groupShortLinkStats: string = '/short-link/v1/stats/group';
  // 访问单个短链接指定时间内访问记录监控数据
  static readonly shortLinkStatsAccessRecord: string = '/short-link/v1/stats/access-record';
  // 访问分组短链接指定时间内访问记录监控数据
  static readonly groupShortLinkStatsAccessRecord: string = '/short-link/v1/stats/access-record/group';
  // 查看用某一用户指定时间内访问曲线
  static readonly groupShortLinkStatsAccess: string = '/short-link/v1/manager-to-user/groupShortLinkStatsAccess'
  // 查看用某一用户指定时间内地区分布
  static readonly groupShortLinkStatsArea: string = '/short-link/v1/manager-to-user/groupShortLinkStatsArea'
  // 查看用某一用户指定时间内24小时分布
  static readonly groupShortLinkStatsHours: string = '/short-link/v1/manager-to-user/groupShortLinkStatsHours'
  // 查看用某一用户指定时间一周分布
  static readonly groupShortLinkStatsWeek: string = '/short-link/v1/manager-to-user/groupShortLinkStatsWeek'
  // 查看用某一用户指定时间内访问用户信息
  static readonly groupShortLinkStatsUser: string = '/short-link/v1/manager-to-user/groupShortLinkStatsUser'
  // 查看用某一用户指定时间内访问记录
  static readonly groupShortLinkStatsRecord: string = '/short-link/v1/manager-to-user/groupShortLinkStatsRecord'
  // 获取基础统计信息
  static readonly getBaseStatsInfo: string = '/short-link/v1/manager-to-user/groupShortLinkStatsRecord'
  //=====================黑名单相关API=============================
  // 分页查询黑名单
  static pageBlackList: string = '/short-link/admin/v1/black-list/page';
  // 添加黑名单
  static addBlackList: string = '/short-link/admin/v1/black-list/add';
  // 删除黑名单
  static updateBlackList: string = '/short-link/admin/v1/black-list/update';
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