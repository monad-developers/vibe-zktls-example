"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Twitter, CheckCircle, AlertCircle, Loader2 } from "lucide-react"
import { useZKTLS } from "@/hooks/useZKTLS"

interface TwitterVerificationProps {
  userAddress: string
  onSuccess: (proofHash: string, attestation: any) => void
}

export function TwitterVerification({ userAddress, onSuccess }: TwitterVerificationProps) {
  const { isLoading, error, attestation, verificationResult, verifyTwitter, reset } = useZKTLS()
  const [isVerified, setIsVerified] = useState(false)

  const handleVerify = async () => {
    await verifyTwitter(userAddress)
  }

  const handleReset = () => {
    reset()
    setIsVerified(false)
  }

  // Handle successful verification
  useEffect(() => {
    if (verificationResult?.success && verificationResult.proofHash && !isVerified) {
      setIsVerified(true)
      onSuccess(verificationResult.proofHash, verificationResult.attestation)
    }
  }, [verificationResult, isVerified, onSuccess])

  return (
    <Card className="w-full max-w-md">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Twitter className="w-5 h-5 text-blue-500" />
          Twitter Verification
        </CardTitle>
        <CardDescription>
          Verify your Twitter account using zkTLS to claim tokens
        </CardDescription>
      </CardHeader>
      
      <CardContent className="space-y-4">
        {!isVerified && !attestation && (
          <Button 
            onClick={handleVerify} 
            disabled={isLoading || !userAddress}
            className="w-full"
            size="lg"
          >
            {isLoading ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Verifying...
              </>
            ) : (
              <>
                <Twitter className="mr-2 h-4 w-4" />
                Verify Twitter Account
              </>
            )}
          </Button>
        )}

        {error && (
          <Alert variant="destructive">
            <AlertCircle className="h-4 w-4" />
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        )}

        {isVerified && attestation && (
          <Alert className="border-green-500 bg-green-50 dark:bg-green-950/20">
            <CheckCircle className="h-4 w-4 text-green-600" />
            <AlertDescription className="text-green-600">
              Twitter account verified successfully!
              <div className="mt-2 text-sm text-muted-foreground">
                {verificationResult?.twitterUsername && (
                  <div>Twitter: @{verificationResult.twitterUsername}</div>
                )}
                <div>Timestamp: {new Date(attestation.timestamp).toLocaleString()}</div>
              </div>
            </AlertDescription>
          </Alert>
        )}

        {isVerified && (
          <Button 
            onClick={handleReset} 
            variant="outline"
            className="w-full"
          >
            Verify Another Account
          </Button>
        )}
      </CardContent>
    </Card>
  )
}