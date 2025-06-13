/**
 * Design System Prompt Guide v2 - Generic Version
 * 
 * Purpose: Create a comprehensive one-shot starter prompt for AI LLM builder tools like lovable.dev and bolt.new
 * to generate a complete, modular, mobile-first design system with all necessary components, layouts, and PWA setup
 * 
 * v2 Updates (2025-06-05):
 * - Made completely generic and reusable for any project type
 * - Added Essential Pages Checklist with complete CRUD operations
 * - Added Desktop Enhancement Guidelines with specific navigation patterns
 * - Added Component Layout Specifications with sticky/floating elements
 * - Added Interaction Patterns section with micro-interactions
 * - Enhanced layout specifications based on real-world app requirements
 */

# Generic Design System Prompt Guide v2

## Overview

This comprehensive guide provides a battle-tested starter prompt for AI LLM builder tools (lovable.dev, bolt.new, etc.) to create complete mobile-first design systems. This template is **completely generic and reusable** for any project type - simply customize Part 1 with your specific project details.

## How to Use This Template

1. **Customize Part 1** with your specific project details
2. **Copy the entire Part 2 prompt** into your AI builder
3. **Get a complete, functional application** with all essential features

## Part 1: Project Customization Header

**Replace this section with your specific project details:**

```
PROJECT CUSTOMIZATION (Replace with your specifics):
- App Name: [Your App Name]
- App Vision: [Brief description of what your app does]
- Target Audience: [Who will use this app - e.g., "Students and teachers", "Small business owners", "Content creators"]
- Color Palette: [e.g., "Bold modern purple", "Professional navy and gold", "Warm sunset colors"]
- UI Style Reference: [e.g., "Clean like WhatsApp", "Professional like Notion", "Playful like Discord"]
- Key Features: [3-5 main features your app will have]
- User Roles: [Define 2-3 user types - e.g., "Students, Teachers, Parents" or "Creators, Viewers, Admins"]
- Inspiration Apps: [2-3 apps that inspired your design direction]
```

---

# Part 2: Complete Design System Prompt

**Copy this entire section and paste into your AI builder after customizing Part 1:**

---

# Complete Mobile-First PWA with Desktop Enhancement

Build a production-ready React application with TypeScript, Tailwind CSS, and shadcn/ui components. Create a comprehensive design system that works flawlessly on mobile devices, looks beautiful on desktop, and serves as the foundation for a scalable application.

**PROJECT CONTEXT**: [INSERT YOUR PROJECT CUSTOMIZATION FROM PART 1 HERE]

Based on the project context above, implement the following comprehensive design system:

## 📋 Essential Pages Checklist

### Core App Pages (MUST IMPLEMENT ALL)

**Authentication Flow:**
- Login page with social auth options
- Registration page with user type selection
- Onboarding flow (3-4 welcome screens explaining key features)
- Forgot password with email verification
- Email verification page

**Main Application Pages:**
- **Home/Dashboard page** with overview of key metrics and recent activity
- **Primary content page** (main interface) with filtering, sorting, creation functionality
- **Communication page** (chat/messaging) with sticky bottom input, file attachments
- **Content management page** (library/saved items) with floating action button, CRUD operations
- **Profile/Settings page** with user info editing, preferences, logout
- **Notifications page** with mark as read, activity filtering

**Essential Secondary Pages:**
- Search results page with universal search across all content
- Help/Support page with FAQs and contact options
- Terms of Service page
- Privacy Policy page
- Contact/Feedback page

### User Role-Specific Pages

**Primary User Type:**
- Detailed item/content pages with full information display
- Creation/submission pages with file upload capabilities
- Progress/analytics tracking page with visual metrics
- Personal planning/organization page

**Secondary User Type (Admin/Creator Role):**
- Management dashboard with user/content oversight
- Creation/editing pages with rich text editor and media support
- Analytics and reporting pages with data visualization
- Bulk operations page for mass actions
- Scheduling/calendar management page

**Tertiary User Type (Supervisor/Monitor Role):**
- Overview dashboard with monitoring capabilities
- Comparison/evaluation pages with rating systems
- Communication hub for direct messaging
- Reports and progress tracking dashboard
- Account/subscription management page

## 🖥️ Desktop Enhancement Guidelines

### Desktop Header Navigation (768px+)
**CRITICAL**: Implement full desktop navigation in header, not just mobile bottom nav.

```jsx
// REQUIRED: Desktop header with full navigation
<header className="hidden md:flex h-16 border-b bg-background/95 backdrop-blur sticky top-0 z-50">
  <div className="container flex items-center justify-between px-6">
    {/* Left: Brand + Main Navigation */}
    <div className="flex items-center space-x-8">
      <Link to="/" className="font-bold text-xl text-primary">
        [Your App Name]
      </Link>
      <nav className="flex items-center space-x-6">
        <Link to="/" className="text-sm font-medium hover:text-primary transition-colors">
          [Primary Page Name]
        </Link>
        <Link to="/[secondary]" className="text-sm font-medium hover:text-primary transition-colors">
          [Secondary Page Name]
        </Link>
        <Link to="/[tertiary]" className="text-sm font-medium hover:text-primary transition-colors">
          [Tertiary Page Name]
        </Link>
        {/* Add role-specific nav items based on user type */}
      </nav>
    </div>
    
    {/* Right: Search + Actions + Profile */}
    <div className="flex items-center space-x-4">
      <Button variant="ghost" size="sm" className="w-64 justify-start">
        <Search className="h-4 w-4 mr-2" />
        Search anything... <kbd className="ml-auto text-xs">⌘K</kbd>
      </Button>
      <Button variant="ghost" size="sm">
        <Bell className="h-4 w-4" />
      </Button>
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="ghost" className="relative h-8 w-8 rounded-full">
            <Avatar className="h-8 w-8">
              <AvatarFallback>UN</AvatarFallback>
            </Avatar>
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end">
          <DropdownMenuItem>Profile</DropdownMenuItem>
          <DropdownMenuItem>Settings</DropdownMenuItem>
          <DropdownMenuSeparator />
          <DropdownMenuItem>Logout</DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </div>
  </div>
</header>
```

### Desktop Layout Patterns
- **Two-column layouts**: Sidebar + main content for detailed pages
- **Multi-panel views**: Multiple content areas side-by-side on large screens
- **Hover interactions**: Tooltips, preview cards, context menus
- **Keyboard shortcuts**: Cmd+K search, ESC to close modals
- **Breadcrumb navigation**: For deep page hierarchies

## 🎯 Component Layout Specifications

### Communication Interface (CRITICAL REQUIREMENTS)
```jsx
// REQUIRED: Communication interface must have sticky bottom input
<div className="flex flex-col h-[calc(100dvh-3.5rem-4rem)] md:h-[calc(100dvh-4rem)]">
  {/* Header */}
  <div className="border-b p-4 bg-background shrink-0">
    <h2>[Communication Page Title]</h2>
  </div>
  
  {/* Messages/Content Area - MUST BE SCROLLABLE */}
  <div className="flex-1 overflow-y-auto p-4 space-y-4">
    {/* Messages or communication content */}
  </div>
  
  {/* Input Area - MUST BE STICKY AT BOTTOM */}
  <div className="border-t p-4 bg-background shrink-0 sticky bottom-0">
    <div className="flex items-end space-x-2">
      <Input 
        placeholder="[Context-appropriate placeholder]..." 
        className="flex-1 min-h-[44px]"
      />
      <Button size="icon">
        <Send className="h-4 w-4" />
      </Button>
    </div>
  </div>
</div>
```

### Content Management Interface (CRITICAL REQUIREMENTS)
```jsx
// REQUIRED: Floating Action Button for creating new content
<div className="relative">
  {/* Content Grid/List */}
  <div className="space-y-4">
    {/* Content items */}
  </div>
  
  {/* REQUIRED: Floating Action Button */}
  <Button 
    className="fixed bottom-20 right-4 md:bottom-6 h-14 w-14 rounded-full shadow-lg z-40"
    size="icon"
    onClick={handleCreateContent}
  >
    <Plus className="h-6 w-6" />
  </Button>
</div>
```

### Primary Content Interface (CRITICAL REQUIREMENTS)
```jsx
// REQUIRED: Sticky filter bar + create content functionality
<div className="space-y-4">
  {/* Sticky Filter Bar */}
  <div className="sticky top-14 md:top-16 z-30 bg-background/95 backdrop-blur py-4 border-b">
    <div className="flex items-center justify-between">
      <div className="flex space-x-2">
        <Button variant={filter === 'all' ? 'default' : 'outline'} size="sm">
          All
        </Button>
        <Button variant={filter === 'category1' ? 'default' : 'outline'} size="sm">
          [Category 1]
        </Button>
        <Button variant={filter === 'category2' ? 'default' : 'outline'} size="sm">
          [Category 2]
        </Button>
        {/* More filters based on content types */}
      </div>
      {user?.role === '[creator_role]' && (
        <Button onClick={handleCreateContent}>
          <Plus className="h-4 w-4 mr-2" />
          Create [Content Type]
        </Button>
      )}
    </div>
  </div>
  
  {/* Content Feed */}
  <div className="space-y-4">
    {/* Content items */}
  </div>
</div>
```

## 🎨 Design System Foundation

### Color System
Create a cohesive color palette based on: [INSERT YOUR COLOR PALETTE FROM PART 1]

```css
:root {
  /* Primary colors - CUSTOMIZE TO YOUR BRAND */
  --primary: [Your primary color HSL];
  --primary-foreground: [Contrasting text color];
  --secondary: [Your secondary color HSL];
  --secondary-foreground: [Contrasting text color];
  
  /* Semantic colors */
  --success: 142 76% 36%;
  --warning: 38 92% 50%;
  --error: 0 84% 60%;
  --info: 199 89% 48%;
  
  /* Neutral palette */
  --background: 0 0% 100%;
  --foreground: 222 47% 11%;
  --card: 0 0% 100%;
  --card-foreground: 222 47% 11%;
  --muted: 210 40% 96%;
  --muted-foreground: 215 16% 47%;
  --border: 214 32% 91%;
  --input: 214 32% 91%;
  --ring: var(--primary);
  
  /* Dynamic viewport height for mobile */
  --vh: 1vh;
}

/* Dark mode variants */
.dark {
  --background: 222 47% 11%;
  --foreground: 210 40% 98%;
  --card: 222 47% 11%;
  --card-foreground: 210 40% 98%;
  --muted: 217 33% 17%;
  --muted-foreground: 215 20% 65%;
  --border: 217 33% 17%;
  --input: 217 33% 17%;
}
```

### Typography Scale
```css
/* Mobile-first responsive typography */
.text-display-xl { font-size: 2.25rem; line-height: 2.5rem; } /* 36px/40px mobile */
.text-display-l { font-size: 1.875rem; line-height: 2.25rem; } /* 30px/36px mobile */
.text-display-m { font-size: 1.5rem; line-height: 2rem; } /* 24px/32px mobile */

/* Scale up for desktop with responsive classes */
@media (min-width: 768px) {
  .text-display-xl { font-size: 4.5rem; line-height: 5rem; } /* 72px/80px desktop */
  .text-display-l { font-size: 3.75rem; line-height: 4.5rem; } /* 60px/72px desktop */
  .text-display-m { font-size: 3rem; line-height: 3.5rem; } /* 48px/56px desktop */
}
```

### Spacing System
Use a consistent 4px base unit (0.25rem) with this scale:
- 2xs: 2px
- xs: 4px  
- sm: 8px
- md: 12px
- base: 16px
- lg: 24px
- xl: 32px
- 2xl: 48px
- 3xl: 64px
- 4xl: 96px

## 🔄 CRUD Operations Requirements

### Content Management CRUD (ESSENTIAL)
```jsx
// REQUIRED: Complete content management
const ContentManagementPage = () => {
  const [items, setItems] = useState([]);
  const [isCreating, setIsCreating] = useState(false);
  const [editingItem, setEditingItem] = useState(null);
  
  // CREATE
  const handleCreateItem = () => {
    setIsCreating(true);
    // Open create item modal/bottom sheet
  };
  
  // READ with search and filters
  const filteredItems = items.filter(item => 
    item.title.includes(searchQuery) || 
    item.content.includes(searchQuery)
  );
  
  // UPDATE
  const handleEditItem = (itemId) => {
    setEditingItem(itemId);
    // Open edit modal/bottom sheet
  };
  
  // DELETE with confirmation
  const handleDeleteItem = (itemId) => {
    // Show confirmation dialog
    // Then delete item
  };
  
  return (
    <div>
      {/* Search bar */}
      <Input placeholder="Search [content type]..." />
      
      {/* Content grid with edit/delete actions */}
      {filteredItems.map(item => (
        <Card key={item.id}>
          <CardContent>
            <h3>{item.title}</h3>
            <p>{item.content}</p>
            <div className="flex space-x-2">
              <Button size="sm" onClick={() => handleEditItem(item.id)}>
                Edit
              </Button>
              <Button size="sm" variant="destructive" onClick={() => handleDeleteItem(item.id)}>
                Delete
              </Button>
            </div>
          </CardContent>
        </Card>
      ))}
      
      {/* Floating create button */}
      <Button 
        className="fixed bottom-20 right-4 md:bottom-6 rounded-full"
        onClick={handleCreateItem}
      >
        <Plus />
      </Button>
    </div>
  );
};
```

### Primary Content CRUD (Creator Role)
```jsx
// REQUIRED: Content creators can create, edit, delete content
const PrimaryContentPage = () => {
  // CREATE content functionality
  const handleCreateContent = () => {
    // Open create content modal with rich text editor
  };
  
  // UPDATE content (edit)
  const handleEditContent = (contentId) => {
    // Open edit modal with existing content data
  };
  
  // DELETE content with confirmation
  const handleDeleteContent = (contentId) => {
    // Show confirmation dialog
  };
  
  return (
    <div>
      {/* Create content button for creators */}
      {user?.role === '[creator_role]' && (
        <Button onClick={handleCreateContent}>
          <Plus className="mr-2" />
          Create [Content Type]
        </Button>
      )}
      
      {/* Content items with edit/delete for own content */}
      {contentItems.map(item => (
        <Card key={item.id}>
          {/* Content display */}
          {item.authorId === user?.id && (
            <div className="flex space-x-2">
              <Button size="sm" onClick={() => handleEditContent(item.id)}>
                Edit
              </Button>
              <Button size="sm" variant="destructive" onClick={() => handleDeleteContent(item.id)}>
                Delete
              </Button>
            </div>
          )}
        </Card>
      ))}
    </div>
  );
};
```

### Profile/Settings CRUD
```jsx
// REQUIRED: User can edit their profile information
const ProfilePage = () => {
  const [isEditing, setIsEditing] = useState(false);
  const [profileData, setProfileData] = useState(user);
  
  const handleSaveProfile = async () => {
    // Save profile changes
    await updateUserProfile(profileData);
    setIsEditing(false);
  };
  
  return (
    <div>
      <Card>
        <CardHeader>
          <div className="flex justify-between">
            <h2>Profile Information</h2>
            <Button onClick={() => setIsEditing(!isEditing)}>
              {isEditing ? 'Cancel' : 'Edit'}
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          {isEditing ? (
            <form onSubmit={handleSaveProfile}>
              <Input 
                value={profileData.name}
                onChange={(e) => setProfileData({...profileData, name: e.target.value})}
                placeholder="Full Name"
              />
              <Input 
                value={profileData.email}
                onChange={(e) => setProfileData({...profileData, email: e.target.value})}
                placeholder="Email"
              />
              <Button type="submit">Save Changes</Button>
            </form>
          ) : (
            <div>
              <p>Name: {profileData.name}</p>
              <p>Email: {profileData.email}</p>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
};
```

## 🎭 Interaction Patterns

### Loading States (REQUIRED)
```jsx
// REQUIRED: Loading states for all async operations
const LoadingCard = () => (
  <Card>
    <CardContent>
      <Skeleton className="h-4 w-3/4 mb-2" />
      <Skeleton className="h-4 w-1/2" />
    </CardContent>
  </Card>
);

// Use in all pages
{isLoading ? <LoadingCard /> : <ActualContent />}
```

### Empty States (REQUIRED)
```jsx
// REQUIRED: Empty states for all lists/collections
const EmptyContentState = () => (
  <div className="text-center py-12">
    <FileText className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
    <h3 className="text-lg font-semibold mb-2">No [content type] yet</h3>
    <p className="text-muted-foreground mb-4">
      Create your first [content item] to get started
    </p>
    <Button onClick={handleCreateContent}>
      <Plus className="mr-2" />
      Create First [Content Type]
    </Button>
  </div>
);
```

### Pull-to-Refresh (Mobile)
```jsx
// REQUIRED: Pull-to-refresh on mobile feeds
const ContentFeedPage = () => {
  const [isRefreshing, setIsRefreshing] = useState(false);
  
  const handleRefresh = async () => {
    setIsRefreshing(true);
    await fetchLatestContent();
    setIsRefreshing(false);
  };
  
  return (
    <div className="touch-action-pan-y">
      {/* Pull-to-refresh indicator */}
      {isRefreshing && (
        <div className="flex justify-center py-4">
          <Spinner />
        </div>
      )}
      {/* Content feed */}
    </div>
  );
};
```

### Swipe Actions (Mobile)
```jsx
// REQUIRED: Swipe-to-delete on mobile lists
const SwipeableContentCard = ({ item, onDelete }) => {
  return (
    <div className="relative overflow-hidden">
      {/* Swipe actions background */}
      <div className="absolute right-0 top-0 bottom-0 bg-destructive flex items-center px-4">
        <Trash2 className="h-5 w-5 text-white" />
      </div>
      
      {/* Main card content */}
      <Card className="relative bg-background">
        <CardContent>
          <h3>{item.title}</h3>
          <p>{item.content}</p>
        </CardContent>
      </Card>
    </div>
  );
};
```

## 🗂️ Complete File Structure

Generate this exact structure with ALL files:

```
src/
├── components/
│   ├── ui/                      # shadcn/ui base components
│   │   ├── button.tsx
│   │   ├── input.tsx
│   │   ├── card.tsx
│   │   ├── avatar.tsx
│   │   ├── badge.tsx
│   │   ├── dialog.tsx
│   │   ├── dropdown-menu.tsx
│   │   ├── skeleton.tsx
│   │   └── [all other shadcn components]
│   ├── layout/                  # Layout components
│   │   ├── app-shell.tsx
│   │   ├── desktop-header.tsx   # REQUIRED: Desktop navigation
│   │   ├── mobile-bottom-nav.tsx
│   │   ├── breadcrumbs.tsx
│   │   └── page-layout.tsx
│   ├── forms/                   # Form components
│   │   ├── create-content-form.tsx
│   │   ├── edit-content-form.tsx
│   │   ├── edit-profile-form.tsx
│   │   ├── search-form.tsx
│   │   └── auth-forms.tsx
│   ├── cards/                   # Card variations
│   │   ├── content-card.tsx     # With edit/delete actions
│   │   ├── communication-card.tsx
│   │   ├── user-card.tsx
│   │   └── stats-card.tsx
│   ├── interactive/             # Interactive components
│   │   ├── floating-action-button.tsx
│   │   ├── swipeable-card.tsx
│   │   ├── pull-to-refresh.tsx
│   │   ├── bottom-sheet.tsx
│   │   └── loading-states.tsx
│   └── pages/                   # All page components
│       ├── auth/
│       │   ├── login-page.tsx
│       │   ├── register-page.tsx
│       │   ├── forgot-password-page.tsx
│       │   └── onboarding-page.tsx
│       ├── main/
│       │   ├── home-page.tsx            # Dashboard/overview
│       │   ├── primary-content-page.tsx # Main content feed with CRUD
│       │   ├── communication-page.tsx   # Chat/messaging with sticky input
│       │   ├── content-management-page.tsx # Content library with FAB and CRUD
│       │   ├── profile-page.tsx         # With edit functionality
│       │   ├── settings-page.tsx
│       │   └── notifications-page.tsx
│       ├── primary-user/
│       │   ├── detail-page.tsx          # Detailed item views
│       │   ├── submission-page.tsx      # Create/submit content
│       │   └── progress-page.tsx        # Personal analytics
│       ├── creator-role/
│       │   ├── management-page.tsx      # Content/user management
│       │   ├── creation-page.tsx        # Rich content creation
│       │   └── analytics-page.tsx       # Performance metrics
│       └── supervisor-role/
│           ├── oversight-page.tsx       # Monitoring dashboard
│           ├── comparison-page.tsx      # Evaluation tools
│           └── communication-page.tsx   # Direct messaging
├── hooks/                       # Custom React hooks
│   ├── use-mobile.tsx
│   ├── use-crud.tsx             # Generic CRUD operations
│   ├── use-infinite-scroll.tsx
│   ├── use-swipe-actions.tsx
│   ├── use-debounce.tsx
│   └── use-local-storage.tsx
├── stores/                      # Zustand state management
│   ├── auth-store.ts
│   ├── content-store.ts         # With CRUD operations for main content
│   ├── communication-store.ts   # Chat/messaging state
│   ├── ui-store.ts              # Global UI state
│   └── user-store.ts            # User profile and preferences
├── services/                    # API services layer
│   ├── content-service.ts       # Full CRUD for main content
│   ├── communication-service.ts # Messaging/chat API
│   ├── auth-service.ts          # Authentication
│   ├── user-service.ts          # User management
│   └── api.ts                   # Base API configuration
├── data/                        # Mock data for development
│   ├── users.ts                 # Mock user data
│   ├── content.ts               # Mock content data
│   ├── communications.ts        # Mock messages/chats
│   └── schemas.ts               # Data schema definitions
├── types/                       # TypeScript type definitions
│   ├── auth.ts                  # Authentication types
│   ├── user.ts                  # User and profile types
│   ├── content.ts               # Content and media types
│   ├── communication.ts         # Chat and messaging types
│   └── api.ts                   # API response types
├── lib/                         # Utility functions
│   ├── utils.ts                 # General utilities
│   ├── cn.ts                    # Class name utility
│   ├── formatters.ts            # Data formatting
│   ├── validators.ts            # Form validation
│   └── constants.ts             # App constants
└── styles/                      # Global styles
    ├── globals.css              # Global CSS with design tokens
    ├── components.css           # Component-specific styles
    └── mobile.css               # Mobile-specific optimizations
```

## 📱 PWA Configuration

### manifest.json (REQUIRED)
```json
{
  "name": "[Your App Name]",
  "short_name": "[Short Name]",
  "description": "[App Description]",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#[Your Primary Color Hex]",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "/icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ],
  "shortcuts": [
    {
      "name": "[Quick Action 1]",
      "short_name": "[Action 1]",
      "description": "[Action description]",
      "url": "/[action-url]",
      "icons": [{ "src": "/icons/shortcut-96.png", "sizes": "96x96" }]
    }
  ]
}
```

### Required Icon Files
Create these exact files in `/public/`:
- `/icons/icon-192.png` (192x192)
- `/icons/icon-512.png` (512x512)
- `/apple-touch-icon.png` (180x180)
- `/favicon.ico` (32x32)

### Mobile Optimizations
```javascript
// utils/viewport.ts - Dynamic viewport height setup
function setDynamicVH() {
  const vh = window.innerHeight * 0.01;
  document.documentElement.style.setProperty('--vh', `${vh}px`);
}

window.addEventListener('resize', setDynamicVH);
window.addEventListener('orientationchange', setDynamicVH);
setDynamicVH();
```

## 🚀 Implementation Checklist

### Phase 1: Core Foundation
- [ ] Set up project with TypeScript + Tailwind + shadcn/ui
- [ ] Implement color system with CSS variables matching your brand
- [ ] Create desktop header navigation with search functionality
- [ ] Create mobile bottom navigation with role-based items
- [ ] Implement basic routing and layout structure

### Phase 2: Essential Pages
- [ ] Authentication flow (login/register/onboarding)
- [ ] Primary content page with filtering and creation
- [ ] Communication page with sticky bottom input
- [ ] Content management page with floating action button
- [ ] Profile/Settings page with editing functionality

### Phase 3: CRUD Operations
- [ ] Content management: Create, Read, Update, Delete
- [ ] Primary content: Create, Read, Update, Delete (for creators)
- [ ] Profile management: Read, Update
- [ ] Search: Universal search functionality across content

### Phase 4: Interactions & Polish
- [ ] Loading states for all async operations
- [ ] Empty states for all collections and lists
- [ ] Pull-to-refresh on mobile content feeds
- [ ] Swipe actions for mobile lists and cards
- [ ] Error handling and toast notifications

### Phase 5: PWA & Performance
- [ ] Add manifest.json with proper app metadata
- [ ] Create all required icon files
- [ ] Implement service worker for offline functionality
- [ ] Optimize performance and bundle size
- [ ] Test thoroughly on actual mobile devices

## 📝 Project Documentation

The system will automatically generate a `project-llms.txt` file with:
- Project overview and architecture decisions
- Development patterns and component guidelines
- File organization and naming conventions
- Next steps for extending functionality
- Maintenance and scaling recommendations

This comprehensive prompt addresses all critical requirements for modern web applications and will generate a complete, functional application with proper desktop navigation, CRUD operations, mobile-optimized interactions, and PWA capabilities.

---

**Usage**: After customizing Part 1 with your project details and pasting this prompt into your AI builder, you'll receive a production-ready foundation that works beautifully across all devices and provides a solid base for rapid development.
