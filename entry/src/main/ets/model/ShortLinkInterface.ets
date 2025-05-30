export interface ShortLink {
  id: string;
  gid: string;
  originUrl: string;
  title: string;
  description?: string;
  validityType: string;
  validityTime?: string;
  domain: string;       // 域名
  shortUri: string;     // 短链接
  fullShortUrl: string; // 完整短链接
  validDateType: number; // 有效期类型 0：永久有效 1：自定义
  validDate?: string;   // 有效期
  createTime: string;   // 创建时间
  describe?: string;    // 描述
  favicon?: string;     // 网站标识
  totalPv: number;      // 历史PV
  todayPv: number;      // 今日PV
  totalUv: number;      // 历史UV
  todayUv: number;      // 今日UV
  totalUip: number;     // 历史UIP
  todayUip: number;     // 今日UIP
}

// 添加访问记录数据类型定义
export  interface AccessRecord {
  createTime?: string;
  ip?: string;
  country?: string;
  province?: string;
  city?: string;
  os?: string;
  browser?: string;
  network?: string;
  device?: string;
  user?: string;
  locale?: string
}

export class ShortLinkStatsData {
  pv: number = 0; // 访问量
  uv: number = 0; // 独立访客数
  uip: number = 0; // 独立IP数
  daily: Array<DailyStats> = [];
  localeCnStats: Array<CountStats> = [];
  localeCnts: Array<CountStats> = []; // 添加这个属性用于兼容MapChart组件
  hourStats: Array<number> = [];
  topIpStats: Array<TopIpStats> = [];
  weekdayStats: Array<number> = [];
  browserStats: Array<BrowserStats> = [];
  osStats: Array<OsStats> = [];
  uvTypeStats: Array<UvTypeStats> = [];
  deviceStats: Array<DeviceStats> = [];
  networkStats: Array<NetworkStats> = [];
}

// 添加统计数据类型定义
export class DailyStats {
  date: string = '';
  pv: number = 0;
  uv: number = 0;
  uip: number = 0;
  count: number = 0;
}

export class CountStats {
  cnt: number = 0;
  locale: string = '';
  ratio: number = 0.0;
}

export class TopIpStats {
  ip: string = '';
  cnt: number = 0;
  ratio: number = 0.0;
}

export class BrowserStats {
  browser: string = '';
  cnt: number = 0;
  ratio: number = 0.0;
}

export class OsStats {
  os: string = '';
  cnt: number = 0;
  ratio: number = 0.0;
}

export class UvTypeStats {
  uvType: string = '';
  cnt: number = 0;
  ratio: number = 0.0;
}

export class DeviceStats {
  device: string = '';
  cnt: number = 0;
  ratio: number = 0.0;
}

export class NetworkStats {
  network: string = '';
  cnt: number = 0;
  ratio: number = 0.0;
}

// 添加地图数据点类型
export class MapDataPoint {
  name: string = '';
  value: number = 0;
}