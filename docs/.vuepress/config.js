module.exports = {
  title: 'Azure AVNM IPAM',
  description: 'Azure Virtual Network Manager (AVNM) IP Address Management (IPAM) Solution and Azure Landing Zones Documentation',
  
  // Theme and layout configuration
  themeConfig: {
    // Repository information
    repo: 'tanure/Azure-AVNM-IPAM',
    repoLabel: 'GitHub',
    docsDir: 'docs',
    editLinks: true,
    editLinkText: 'Edit this page on GitHub',
    
    // Navigation
    nav: [
      { text: 'Home', link: '/' }     
    ],
    
    // Sidebar configuration
    sidebar: [
      {
        title: 'Getting Started',
        collapsable: false,
        children: [
          ['/', 'Introduction']
        ]
      }
    ],
    
    // Search
    search: true,
    searchMaxSuggestions: 10,
    
    // Page meta
    lastUpdated: 'Last Updated'
  },
  
  // Plugins
  plugins: [
    [
      '@vuepress/plugin-search',
      {
        searchMaxSuggestions: 10
      }
    ]
  ],
  
  // Markdown configuration
  markdown: {
    lineNumbers: true,
    anchor: {
      permalink: true,
      permalinkBefore: true,
      permalinkSymbol: '#'
    }
  },
  
  // Head configuration for SEO and favicon
  head: [
    ['link', { rel: 'icon', href: '/favicon.ico' }],
    ['meta', { name: 'viewport', content: 'width=device-width,initial-scale=1,user-scalable=no' }],
    ['meta', { name: 'keywords', content: 'Azure, AVNM, IPAM, Bicep, Landing Zones, Documentation' }],
    ['meta', { name: 'author', content: 'Azure AVNM IPAM Contributors' }]
  ],
  
  // Build configuration
  dest: 'docs/.vuepress/dist',
  
  // Base URL for GitHub Pages
  base: '/Azure-AVNM-IPAM/',
  
  // Service worker
  serviceWorker: true
}
