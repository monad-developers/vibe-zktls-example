"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { TwitterVerification } from "@/components/TwitterVerification"
import { Shield, Key, Lock, Wallet, Loader2, CheckCircle } from "lucide-react"
import { useTokenClaim } from "@/hooks/useTokenClaim"

export default function Home() {
  const [walletConnected, setWalletConnected] = useState(false)
  const [userAddress, setUserAddress] = useState("")
  const [verificationComplete, setVerificationComplete] = useState(false)
  const [attestation, setAttestation] = useState<any>(null)
  const [hasClaimed, setHasClaimed] = useState(false)
  
  const { isLoading: isClaimLoading, error: claimError, txHash, claimTokens, checkHasClaimed } = useTokenClaim()
  const contractAddress = process.env.NEXT_PUBLIC_CONTRACT_ADDRESS || ""

  const connectWallet = async () => {
    if (typeof window.ethereum !== "undefined") {
      try {
        const accounts = await window.ethereum.request({ 
          method: "eth_requestAccounts" 
        })
        setUserAddress(accounts[0])
        setWalletConnected(true)
      } catch (error) {
        console.error("Wallet connection failed:", error)
      }
    } else {
      alert("Please install MetaMask to continue")
    }
  }

  useEffect(() => {
    if (userAddress && contractAddress) {
      checkHasClaimed(userAddress, contractAddress).then(setHasClaimed)
    }
  }, [userAddress, contractAddress, checkHasClaimed])

  const handleVerificationSuccess = (hash: string, attestationData: any) => {
    setAttestation(attestationData)
    setVerificationComplete(true)
    console.log("Verification successful:", { hash, attestation: attestationData })
  }
  
  const handleClaimTokens = async () => {
    if (!contractAddress) return
    await claimTokens(contractAddress, attestation)
    if (!claimError) {
      setHasClaimed(true)
    }
  }

  return (
    <main className="min-h-screen bg-gradient-to-b from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800">
      <div className="container mx-auto px-4 py-16">
        <div className="text-center mb-12">
          <h1 className="text-6xl font-bold mb-4 bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
            Vibe zkTLS
          </h1>
          <p className="text-xl text-slate-600 dark:text-slate-300">
            Verify your Twitter identity with zkTLS to claim tokens
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-6 mb-12">
          <Card>
            <CardHeader>
              <Shield className="w-10 h-10 text-blue-600 mb-2" />
              <CardTitle>Privacy First</CardTitle>
            </CardHeader>
            <CardContent>
              <CardDescription>
                Verify your Twitter account without revealing sensitive data
              </CardDescription>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <Key className="w-10 h-10 text-purple-600 mb-2" />
              <CardTitle>zkTLS Powered</CardTitle>
            </CardHeader>
            <CardContent>
              <CardDescription>
                Cryptographic proofs ensure data authenticity and privacy
              </CardDescription>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <Lock className="w-10 h-10 text-green-600 mb-2" />
              <CardTitle>On-Chain Claims</CardTitle>
            </CardHeader>
            <CardContent>
              <CardDescription>
                Claim VIBE tokens on Monad testnet after verification
              </CardDescription>
            </CardContent>
          </Card>
        </div>

        {!walletConnected && (
          <Card className="max-w-md mx-auto">
            <CardHeader>
              <CardTitle className="text-2xl">Connect Your Wallet</CardTitle>
              <CardDescription>
                Connect your wallet to start the verification process
              </CardDescription>
            </CardHeader>
            <CardContent>
              <Button onClick={connectWallet} className="w-full" size="lg">
                <Wallet className="mr-2 h-4 w-4" />
                Connect MetaMask
              </Button>
            </CardContent>
          </Card>
        )}

        {walletConnected && !verificationComplete && (
          <div className="flex justify-center">
            <TwitterVerification 
              userAddress={userAddress}
              onSuccess={handleVerificationSuccess}
            />
          </div>
        )}

        {verificationComplete && (
          <Card className="max-w-md mx-auto">
            <CardHeader>
              <CardTitle className="text-2xl text-green-600">
                {hasClaimed ? "Tokens Claimed!" : "Ready to Claim!"}
              </CardTitle>
              <CardDescription>
                {hasClaimed 
                  ? "You have successfully claimed your VIBE tokens." 
                  : "Your Twitter verification is complete. You can now claim tokens."}
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="text-sm text-muted-foreground">
                <div>Wallet: {userAddress.slice(0, 6)}...{userAddress.slice(-4)}</div>
                {attestation && (
                  <div>Attestation ID: {attestation.attestationId?.slice(0, 10)}...</div>
                )}
              </div>
              
              {claimError && (
                <Alert variant="destructive">
                  <AlertDescription>{claimError}</AlertDescription>
                </Alert>
              )}
              
              {txHash && (
                <Alert className="border-green-500 bg-green-50">
                  <CheckCircle className="h-4 w-4 text-green-600" />
                  <AlertDescription>
                    Transaction: {txHash.slice(0, 10)}...
                    <a 
                      href={`https://testnet.monadexplorer.com/tx/${txHash}`}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="underline ml-2"
                    >
                      View on Explorer
                    </a>
                  </AlertDescription>
                </Alert>
              )}
              
              {!hasClaimed && (
                <Button 
                  onClick={handleClaimTokens} 
                  disabled={isClaimLoading || !contractAddress}
                  className="w-full" 
                  size="lg"
                >
                  {isClaimLoading ? (
                    <>
                      <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                      Claiming tokens...
                    </>
                  ) : (
                    "Claim 100 VIBE Tokens"
                  )}
                </Button>
              )}
              
              {hasClaimed && (
                <Button disabled className="w-full" size="lg">
                  <CheckCircle className="mr-2 h-4 w-4" />
                  Tokens Already Claimed
                </Button>
              )}
            </CardContent>
          </Card>
        )}
      </div>
    </main>
  )
}