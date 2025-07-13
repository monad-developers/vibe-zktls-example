export const primusConfig = {
  appId: process.env.PRIMUS_APP_ID || '',
  appSecret: process.env.PRIMUS_APP_SECRET || '',
  baseUrl: 'https://api.primuslabs.xyz',
}

export const zkTLSConfig = {
  mode: 'proxy' as const, // 'proxy' or 'mpc'
  verifyEndpoint: '/verify',
  templateId: '', // Will be set after creating template in Primus Developer Hub
}

export function validatePrimusConfig() {
  if (!primusConfig.appId || !primusConfig.appSecret) {
    throw new Error('Missing Primus SDK credentials. Please set PRIMUS_APP_ID and PRIMUS_APP_SECRET')
  }
}