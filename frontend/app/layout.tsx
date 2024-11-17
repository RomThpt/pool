"use client";
import "@rainbow-me/rainbowkit/styles.css";
import { getDefaultConfig, RainbowKitProvider } from "@rainbow-me/rainbowkit";
import { WagmiProvider } from "wagmi";
import { hardhat } from "wagmi/chains";
import { QueryClientProvider, QueryClient } from "@tanstack/react-query";
import { ChakraProvider } from "@chakra-ui/react";

const config = getDefaultConfig({
    appName: "My RainbowKit App",
    projectId: process.env.NEXT_PUBLIC_RAINBOWKIT_PROJECT_ID as string,
    chains: [hardhat],
    ssr: true, // If your dApp uses server side rendering (SSR)
});
const queryClient = new QueryClient();

export default function RootLayout({
    children,
}: Readonly<{
    children: React.ReactNode;
}>) {
    return (
        <html lang="en">
            <body>
                <WagmiProvider config={config}>
                    <QueryClientProvider client={queryClient}>
                        <RainbowKitProvider>
                            <ChakraProvider>{children}</ChakraProvider>
                        </RainbowKitProvider>
                    </QueryClientProvider>
                </WagmiProvider>
            </body>
        </html>
    );
}
