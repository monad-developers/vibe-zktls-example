import { useState, useCallback } from 'react'
import { primusSDK } from '@/lib/primus-sdk'
import type { AttestationResult, VerificationResult } from '@/lib/primus-sdk'

export interface UseZKTLSReturn {
  isLoading: boolean
  error: string | null
  attestation: AttestationResult | null
  verificationResult: VerificationResult | null
  verifyTwitter: (userAddress: string) => Promise<void>
  reset: () => void
}

export function useZKTLS(): UseZKTLSReturn {
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [attestation, setAttestation] = useState<AttestationResult | null>(null)
  const [verificationResult, setVerificationResult] = useState<VerificationResult | null>(null)

  const verifyTwitter = useCallback(async (userAddress: string) => {
    setIsLoading(true)
    setError(null)
    
    try {
      // Initialize SDK and verify Twitter
      const result = await primusSDK.verifyTwitter(userAddress)
      setVerificationResult(result)
      
      if (result.success && result.attestation) {
        setAttestation(result.attestation)
      } else {
        throw new Error(result.error || 'Twitter verification failed')
      }
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Unknown error occurred'
      setError(message)
      console.error('Twitter verification error:', err)
    } finally {
      setIsLoading(false)
    }
  }, [])

  const reset = useCallback(() => {
    setIsLoading(false)
    setError(null)
    setAttestation(null)
    setVerificationResult(null)
  }, [])

  return {
    isLoading,
    error,
    attestation,
    verificationResult,
    verifyTwitter,
    reset
  }
}