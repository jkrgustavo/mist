import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
    plugins: [tailwindcss(), react()],
    publicDir: path.resolve(__dirname, 'public'), // Static assets
    resolve: {
        alias: {
            '@': path.resolve(__dirname, 'client/shadcn'),
            'melange.js': path.resolve(__dirname, '_build/default/client/output/node_modules/melange.js'),
            'melange': path.resolve(__dirname, '_build/default/client/output/node_modules/melange'),
            'reason-react': path.resolve(__dirname, '_build/default/client/output/node_modules/reason-react'),
        },
    },
    build: {
        outDir: path.resolve(__dirname, 'dist'), // Output to dist/
        rollupOptions: {
            input: {
                main: path.resolve(__dirname, 'client/js/main.js'), // Entry point
                // index: path.resolve(__dirname, 'public/index.html') // HTML entry
            }
        },
    },
    server: {
        port: 5173, // Default Vite dev server port (adjust if needed)
    },
})
