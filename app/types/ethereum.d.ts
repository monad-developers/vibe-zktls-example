interface Window {
  ethereum?: {
    request: (args: { method: string; params?: any[] }) => Promise<any>
    on: (event: string, callback: Function) => void
    removeListener: (event: string, callback: Function) => void
    isMetaMask?: boolean
  }
}