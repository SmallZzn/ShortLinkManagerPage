import http from '@ohos.net.http';

class RequestParams {
  username?: string;
  current: number;
  size: number;

  constructor(username: string = '', current: number = 1, size: number = 10) {
    this.username = username;
    this.current = current;
    this.size = size;
  }
}

class ResponseData {
  code: number = 0;
  message: string = '';
  data: {
    records: Array<Record<string, string | number>>;
    total: number;
  } = {
    records: [],
    total: 0
  };

  constructor(code: number = 0, message: string = '', data: { records: Array<Record<string, string | number>>, total: number } = { records: [], total: 0 }) {
    this.code = code;
    this.message = message;
    this.data = data;
  }
}

export const httpRequestGet = async (url: string, params: RequestParams): Promise<ResponseData> => {
  // 构建查询字符串
  let queryParams = '';
  for (let key in params) {
    if (params[key] !== undefined && params[key] !== '') {
      queryParams += queryParams ? '&' : '?';
      queryParams += `${key}=${encodeURIComponent(params[key])}`;
    }
  }

  const fullUrl = url + queryParams;
  
  try {
    let httpRequest = http.createHttp();
    let response = await httpRequest.request(fullUrl, {
      method: http.RequestMethod.GET,
      header: {
        'Content-Type': 'application/json'
      }
    });

    let result = new ResponseData();
    if (response.responseCode === 200) {
      let responseData = JSON.parse(response.result.toString());
      result.code = responseData.code;
      result.message = responseData.message;
      result.data = responseData.data;
    }

    httpRequest.destroy();
    return result;
  } catch (error) {
    console.error('HTTP请求失败:', error.message);
    return new ResponseData(-1, '请求失败', { records: [], total: 0 });
  }
} 