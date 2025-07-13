// Twitter verification template ID
export const TWITTER_TEMPLATE_ID = '2e3160ae-8b1e-45e3-8c59-426366278b9d'

export interface AttestationResult {
  attestationId?: string
  recipient: string
  templateId?: string
  data: string
  signatures: string[]
  timestamp: number
  attestors: Array<{
    attestorAddr: string
    url: string
  }>
  request: {
    url: string
    method: string
    header: string
    body: string
  }
  attConditions: string
  additionParams: string
  reponseResolve: Array<{
    keyName: string
    parsePath: string
    parseType: string
  }>
  hash?: string
}

export interface VerificationResult {
  success: boolean
  attestation?: AttestationResult
  proofHash?: string
  twitterUsername?: string
  error?: string
}

// Dynamic import to avoid SSR issues
let PrimusZKTLS: any = null

export class PrimusSDKClient {
  private sdk: any = null
  private initialized = false

  async init() {
    if (this.initialized || typeof window === 'undefined') return
    
    try {
      // Dynamic import for client-side only
      const { PrimusZKTLS: PrimusSDK } = await import('@primuslabs/zktls-js-sdk')
      PrimusZKTLS = PrimusSDK
      
      // Get credentials from API
      const response = await fetch('/api/zktls/config')
      const { appId, appSecret } = await response.json()
      
      this.sdk = new PrimusZKTLS()
      const result = await this.sdk.init(appId, appSecret)
      
      if (!result) {
        throw new Error('Failed to initialize Primus SDK')
      }
      
      this.initialized = true
      console.log('Primus SDK initialized')
    } catch (error) {
      console.error('Failed to initialize Primus SDK:', error)
      throw error
    }
  }

  async verifyTwitter(userAddress: string): Promise<VerificationResult> {
    try {
      if (!this.initialized) {
        await this.init()
      }

      if (!this.sdk) {
        throw new Error('Primus SDK not initialized')
      }

      // Generate attestation request
      const request = this.sdk.generateRequestParams(TWITTER_TEMPLATE_ID, userAddress)
      
      // Set zkTLS mode to proxy
      request.setAttMode({
        algorithmType: 'proxytls',
      })

      // Convert request to string and sign
      const requestStr = request.toJsonString()
      const signedRequestStr = await this.sdk.sign(requestStr)

      // Start attestation process
      console.log('Starting Twitter attestation...')
      const attestation = await this.sdk.startAttestation(signedRequestStr)
      console.log('Attestation result:', attestation)

      // Verify signature
      const verifyResult = await this.sdk.verifyAttestation(attestation)
      console.log('Verification result:', verifyResult)

      if (verifyResult) {
        // Generate proof hash for on-chain verification
        const proofHash = this.generateProofHash(attestation)
        const twitterUsername = this.extractTwitterUsername(attestation)
        
        return {
          success: true,
          attestation: attestation,
          proofHash,
          twitterUsername
        }
      } else {
        return {
          success: false,
          error: 'Attestation verification failed'
        }
      }
    } catch (error) {
      console.error('Twitter verification error:', error)
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error occurred'
      }
    }
  }

  private extractTwitterUsername(attestation: AttestationResult): string {
    try {
      // Parse the data field which contains {"screen_name":"username"}
      const dataObj = JSON.parse(attestation.data)
      return dataObj.screen_name || ''
    } catch (error) {
      console.error('Failed to parse Twitter username:', error)
      return ''
    }
  }

  private generateProofHash(attestation: AttestationResult): string {
    const twitterUsername = this.extractTwitterUsername(attestation)
    const dataStr = JSON.stringify({
      twitterUsername,
      userAddress: attestation.recipient,
      timestamp: attestation.timestamp
    })
    
    return '0x' + Buffer.from(dataStr).toString('hex').slice(0, 64)
  }
}

export const primusSDK = new PrimusSDKClient()