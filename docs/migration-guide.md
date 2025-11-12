# Migration Guide

[← Back to Documentation](./README.md)

## Overview

This guide helps you migrate your API safely through version changes using Treaty's versioning capabilities.

## Migration Strategies

### Strategy 1: Parallel Versions (Recommended)

Run multiple versions simultaneously while transitioning clients.

**Advantages:**
- Zero downtime
- Gradual client migration
- Easy rollback
- Both versions tested in production

**Timeline:**
1. Add new version
2. Test new version with select clients
3. Mark old version as deprecated
4. Migrate clients to new version
5. Remove old version after transition period

### Strategy 2: Feature Flags

Use feature flags to toggle between implementations.

**Advantages:**
- Quick rollback
- A/B testing capability
- Controlled rollout

**Disadvantages:**
- More complex code
- Requires feature flag system

### Strategy 3: Breaking Change with Migration Period

Announce breaking changes with deprecation period.

**Advantages:**
- Cleaner codebase
- Forced upgrades
- Clear timeline

**Disadvantages:**
- May break existing integrations
- Requires clear communication

## Migration Scenarios

### Scenario 1: Adding Optional Fields (Non-Breaking)

**Situation:** Add new optional fields without affecting existing clients.

**Before (Version 1):**
```ruby
version 1, default: true do
  strategy Treaty::Strategy::ADAPTER

  response 200 do
    object :post do
      string :id
      string :title
      string :content
    end
  end

  delegate_to Posts::ShowService
end
```

**After (Version 1 - Updated):**
```ruby
version 1, default: true do
  strategy Treaty::Strategy::ADAPTER

  response 200 do
    object :post do
      string :id
      string :title
      string :content
      string :author        # New optional field
      datetime :created_at  # New optional field
    end
  end

  delegate_to Posts::ShowService
end
```

**Impact:** ✅ Non-breaking - existing clients continue to work.

### Scenario 2: Changing Field Structure (Breaking)

**Situation:** Change flat author field to nested object.

**Before (Version 1):**
```ruby
version 1 do
  strategy Treaty::Strategy::ADAPTER

  response 200 do
    object :post do
      string :id
      string :title
      string :author_name   # Flat structure
      string :author_email
    end
  end

  delegate_to Posts::V1::ShowService
end
```

**After (Add Version 2):**
```ruby
# Keep Version 1 for existing clients
version 1 do
  deprecated true  # Mark as deprecated
  strategy Treaty::Strategy::ADAPTER

  response 200 do
    object :post do
      string :id
      string :title
      string :author_name
      string :author_email
    end
  end

  delegate_to Posts::V1::ShowService
end

# Add Version 2 with new structure
version 2, default: true do
  strategy Treaty::Strategy::ADAPTER

  response 200 do
    object :post do
      string :id
      string :title

      object :author do    # Nested structure
        string :name
        string :email
      end
    end
  end

  delegate_to Posts::V2::ShowService
end
```

**Timeline:**
1. **Day 1**: Deploy Version 2, keep Version 1 working
2. **Week 1-4**: Notify clients to migrate
3. **Month 2**: Most clients migrated
4. **Month 3**: Remove Version 1

### Scenario 3: Renaming Fields (Breaking)

**Situation:** Rename `body` to `content` for clarity.

**Before (Version 1):**
```ruby
version 1 do
  request do
    object :post do
      string :title
      string :body
    end
  end
end
```

**Migration with Adaptation:**
```ruby
# Version 1: Keep old field name
version 1 do
  deprecated true
  strategy Treaty::Strategy::ADAPTER

  request do
    object :post do
      string :title
      string :body, :required, as: :content  # Transform to new name
    end
  end

  delegate_to Posts::CreateService  # Service expects :content
end

# Version 2: Use new field name
version 2, default: true do
  strategy Treaty::Strategy::ADAPTER

  request do
    object :post do
      string :title
      string :content  # New field name
    end
  end

  delegate_to Posts::CreateService
end
```

**Result:**
- Version 1 clients: Send `body` → Transformed to `content` for service
- Version 2 clients: Send `content` → Used directly
- Service receives consistent `content` field from both versions

### Scenario 4: Adding Required Fields (Breaking)

**Situation:** Make category field required.

**Migration Path:**

**Phase 1: Add as optional**
```ruby
version 1, default: true do
  request do
    object :post do
      string :title
      string :content
      string :category, :optional, default: "general"  # Optional with default
    end
  end
end
```

**Phase 2: Make required in new version**
```ruby
# Version 1: Category optional
version 1 do
  deprecated true

  request do
    object :post do
      string :title, :required
      string :content, :required
      string :category, :optional, default: "general"
    end
  end

  delegate_to Posts::V1::CreateService
end

# Version 2: Category required
version 2, default: true do
  request do
    object :post do
      string :title
      string :content
      string :category  # Now required
    end
  end

  delegate_to Posts::V2::CreateService
end
```

### Scenario 5: Removing Fields (Breaking)

**Situation:** Remove deprecated `summary` field.

**Migration Path:**

**Phase 1: Mark as deprecated (documentation only)**
```ruby
version 1, default: true do
  request do
    object :post do
      string :title
      string :summary, :optional  # Deprecated - will be removed
      string :content
    end
  end
end
```

**Phase 2: Create new version without field**
```ruby
# Version 1: Keep field
version 1 do
  deprecated true

  request do
    object :post do
      string :title, :required
      string :summary, :optional  # Still accepted
      string :content, :required
    end
  end

  delegate_to Posts::V1::CreateService
end

# Version 2: Remove field
version 2, default: true do
  request do
    object :post do
      string :title
      string :content
      # summary field removed
    end
  end

  delegate_to Posts::V2::CreateService
end
```

### Scenario 6: Changing Validation Rules (Breaking)

**Situation:** Restrict status values to specific list.

**Before:**
```ruby
version 1 do
  request do
    object :post do
      string :status, :optional  # Any string accepted
    end
  end
end
```

**After:**
```ruby
# Version 1: Keep old validation
version 1 do
  deprecated true

  request do
    object :post do
      string :status, :optional  # Still accepts any string
    end
  end

  delegate_to Posts::V1::CreateService
end

# Version 2: Add strict validation
version 2, default: true do
  request do
    object :post do
      string :status, :required, in: %w[draft published archived]  # Restricted
    end
  end

  delegate_to Posts::V2::CreateService
end
```

## Migration Timeline Template

### Week 1: Preparation
- [ ] Analyze breaking changes
- [ ] Plan new version structure
- [ ] Create migration documentation
- [ ] Notify API consumers

### Week 2-3: Development
- [ ] Implement new version
- [ ] Keep old version working
- [ ] Mark old version as deprecated
- [ ] Add tests for both versions
- [ ] Update API documentation

### Week 4: Deployment
- [ ] Deploy to staging
- [ ] Test both versions
- [ ] Deploy to production
- [ ] Monitor error rates
- [ ] Send migration reminders

### Week 5-8: Migration Period
- [ ] Monitor version usage
- [ ] Support client migrations
- [ ] Track migration progress
- [ ] Send final migration warnings

### Week 9: Cleanup
- [ ] Verify all clients migrated
- [ ] Remove old version
- [ ] Clean up old service code
- [ ] Update documentation

## Code Organization for Multiple Versions

### Option 1: Separate Service Classes

```ruby
# app/services/posts/v1/create_service.rb
module Posts
  module V1
    class CreateService
      def self.call(params:)
        # V1 logic
      end
    end
  end
end

# app/services/posts/v2/create_service.rb
module Posts
  module V2
    class CreateService
      def self.call(params:)
        # V2 logic
      end
    end
  end
end

# app/services/posts/stable/create_service.rb
module Posts
  module Stable
    class CreateService
      def self.call(params:)
        # Latest stable logic
      end
    end
  end
end
```

### Option 2: Adapters with Shared Core

```ruby
# app/services/posts/create_service.rb
module Posts
  class CreateService
    def self.call(params:)
      # Core business logic
      Post.create!(params[:post])
    end
  end
end

# Treaty handles adaptation
version 1 do
  request do
    object :post do
      string :body, as: :content  # Adapt old field name
    end
  end

  delegate_to Posts::CreateService
end

version 2 do
  request do
    object :post do
      string :content  # New field name
    end
  end

  delegate_to Posts::CreateService
end
```

### Option 3: Version Parameter

```ruby
# app/services/posts/create_service.rb
module Posts
  class CreateService
    def self.call(params:, version: 2)
      case version
      when 1
        handle_v1(params)
      when 2
        handle_v2(params)
      end
    end

    private

    def self.handle_v1(params)
      # V1 logic
    end

    def self.handle_v2(params)
      # V2 logic
    end
  end
end

# Treaty passes version
version 1 do
  delegate_to Posts::CreateService, with: { version: 1 }
end

version 2 do
  delegate_to Posts::CreateService, with: { version: 2 }
end
```

## Migration Checklist

### Before Making Breaking Changes

- [ ] Document what's changing
- [ ] Identify affected clients
- [ ] Plan migration timeline
- [ ] Prepare communication
- [ ] Test backward compatibility

### When Implementing New Version

- [ ] Create new version in treaty
- [ ] Keep old version working
- [ ] Mark old version as deprecated
- [ ] Add tests for both versions
- [ ] Document differences
- [ ] Update API docs

### During Migration Period

- [ ] Monitor version usage metrics
- [ ] Track error rates per version
- [ ] Provide migration support
- [ ] Send regular reminders
- [ ] Answer client questions

### After Migration Complete

- [ ] Verify no traffic on old version
- [ ] Remove old version code
- [ ] Clean up deprecated services
- [ ] Update documentation
- [ ] Announce completion

## Communication Templates

### Initial Announcement

```
Subject: API Version 2.0 Available - Action Required

Dear API Users,

We're excited to announce API Version 2.0 with the following improvements:
- [List improvements]

Breaking Changes:
- [List breaking changes]

Timeline:
- Today: Version 2.0 available, Version 1.0 still supported
- [Date + 30 days]: Version 1.0 marked deprecated
- [Date + 90 days]: Version 1.0 will be removed

Migration Guide: [URL]

Please upgrade at your earliest convenience.
```

### Deprecation Warning

```
Subject: API Version 1.0 Deprecation - 30 Days Remaining

Your application is still using API Version 1.0, which will be removed in 30 days.

Please upgrade to Version 2.0 before [date].

Migration Guide: [URL]
Support: [contact]
```

### Final Warning

```
Subject: URGENT: API Version 1.0 Removal in 7 Days

Final reminder: API Version 1.0 will be removed on [date].

Your application will stop working if not upgraded.

Action required: Update to Version 2.0 immediately.

Emergency support: [contact]
```

## Monitoring Version Usage

### Track version usage in controller

```ruby
class ApplicationController < ActionController::API
  before_action :log_api_version

  private

  def log_api_version
    version = request.params[:version] ||
              request.headers['API-Version'] ||
              'default'

    Rails.logger.info(
      "API Version: #{version}, " \
      "Endpoint: #{controller_name}##{action_name}, " \
      "Client: #{request.headers['User-Agent']}"
    )

    # Send to metrics system
    # Metrics.increment("api.version.#{version}.requests")
  end
end
```

## Best Practices

### 1. Always Use Deprecation Period

Don't remove versions immediately. Give clients time to migrate.

```ruby
# Bad - no deprecation period
# Day 1: Version 2 added
# Day 2: Version 1 removed ✗

# Good - gradual migration
# Week 1: Version 2 added
# Week 2: Version 1 deprecated
# Month 3: Version 1 removed ✓
```

### 2. Document Everything

Create clear migration guides:
- What changed
- Why it changed
- How to migrate
- Timeline
- Support contacts

### 3. Monitor Actively

Track version usage to:
- Identify clients still on old versions
- Measure migration progress
- Detect issues early

### 4. Communicate Clearly

Send multiple notifications:
- Initial announcement
- Regular reminders
- Final warnings
- Completion notice

### 5. Test Both Versions

Ensure both old and new versions work during migration period:

```ruby
RSpec.describe "API Migration" do
  context "Version 1 (deprecated)" do
    it "still works during migration period" do
      # Test old version
    end
  end

  context "Version 2 (current)" do
    it "works with new structure" do
      # Test new version
    end
  end
end
```

## Next Steps

- [Versioning](./versioning.md) - detailed versioning documentation
- [Strategies](./strategies.md) - understanding strategies
- [Examples](./examples.md) - practical examples

[← Back to Documentation](./README.md)
