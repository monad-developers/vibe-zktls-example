import { NextRequest, NextResponse } from 'next/server'
import { PrimusZKTLS } from '@primuslabs/zktls-js-sdk'

export async function POST(request: NextRequest) {
  try {
    const { signParams } = await request.json()

    if (!signParams) {
      return NextResponse.json(
        { error: 'signParams is required' },
        { status: 400 }
      )
    }

    // Validate environment variables
    const appId = process.env.PRIMUS_APP_ID
    const appSecret = process.env.PRIMUS_APP_SECRET

    if (!appId || !appSecret) {
      return NextResponse.json(
        { error: 'Primus SDK credentials not configured' },
        { status: 500 }
      )
    }

    // Create a PrimusZKTLS object
    const primusZKTLS = new PrimusZKTLS()

    // Set appId and appSecret through the initialization function
    await primusZKTLS.init(appId, appSecret)

    // Sign the attestation request
    console.log('signParams=', signParams)
    const signResult = await primusZKTLS.sign(signParams)
    console.log('signResult=', signResult)

    // Return signed result
    return NextResponse.json({ signResult })

  } catch (error) {
    console.error('Primus signing error:', error)
    return NextResponse.json(
      { 
        error: 'Signing failed', 
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    )
  }
}