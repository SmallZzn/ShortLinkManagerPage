export class DailyStats {
  date: string = '';
  pv: number = 0;
  uv: number = 0;
  uip: number = 0;
}

export class ShortLinkStatsData {
  pv: number = 0; // 访问量
  uv: number = 0; // 独立访客数
  uip: number = 0; // 独立IP数
  daily: Array<DailyStats> = [];
}

export class User {
  id: number = 0;
  username: string = '';
  password: string = '';
  realName: string = '';
  phone: string = '';
  mail: string = '';
  deletionTime: number = 0;
  createTime: string = '';
  updateTime: string = '';
  delFlag: number = 0;
}

export interface OverviewData {
  title: string;
  value: string;
  total: string;
  icon: string;
}

export interface StatsMenuItem {
  key: string;
  title: string;
}

export class Manager {
  id: number = 0;
  username: string = '';
  password: string = '';
  realName: string = '';
  phone: string = '';
  mail: string = '';
  deletionTime: number = 0;
  createTime: string = '';
  updateTime: string = '';
  delFlag: number = 0;
  isSuper: number = 0;
}

// 分配项（用户或公司）
export class AssignItem {
  id: number = 0;
  username: string = '';
  managerName: string = '';
  userType: number = 0; // 0: 个人用户, 1: 公司
  createTime: string = '';
  updateTime: string = '';
  delFlag: number = 0;
}

// 分配列表响应
export class AssignedListResponse {
  assignedList: Array<AssignItem> = [];
  unAssignedList: Array<AssignItem> = [];
  assignedTotal: number = 0; // 已分配总数
  unassignedTotal: number = 0; // 未分配总数
}

// 获取分配列表参数
export class AssignListParams {
  managerId?: number;
  managerName?: string;
  page?: number;
  size?: number;
  keyword?: string;
  status?: string;
}

// 分配用户参数
export class AssignUserParams {
  managerId?: number;
  managerName?: string;
  userId?: number;
  username?: string;
  userType?: number;
}

