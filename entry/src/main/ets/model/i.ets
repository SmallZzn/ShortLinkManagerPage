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