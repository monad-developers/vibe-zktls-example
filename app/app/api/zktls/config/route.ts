import { NextResponse } from 'next/server'

export async function GET() {
  // Only return credentials if they are configured
  const appId = process.env.PRIMUS_APP_ID
  const appSecret = process.env.PRIMUS_APP_SECRET

  if (!appId || !appSecret) {
    return NextResponse.json(
      { error: 'Primus SDK credentials not configured' },
      { status: 500 }
    )
  }

  // IMPORTANT: In production, you should implement proper authentication
  // and rate limiting to protect these credentials
  return NextResponse.json({
    appId,
    appSecret
  })
}