---
name: AWSAgent
description: AWS Agent - Cloud Infrastructure Management
type: agent
subagent_type: "AWSAgent"
---

# AWS-Agent Specification

**Agent ID**: 301
**Type**: Infrastructure Management
**Category**: Coding Agents
**Priority**: 🔴 Critical
**Status**: 📋 Specification Phase
**Version**: 1.0.0

---

## 🎯 Purpose

**Mission**: AWSリソースを自律的に管理し、Service-as-Agent モデルを実現する

**Core Capabilities**:
1. AWS multi-account resource management
2. Service-as-Agent model implementation
3. Historical agent assignment and governance
4. Cost optimization and monitoring

---

## 📊 Quick Reference

### Identity

| Attribute | Value |
|-----------|-------|
| **Agent Name** | `AWSAgent` |
| **Agent ID** | 301 |
| **Category** | Infrastructure Management |
| **Execution Mode** | Autonomous + Interactive |
| **LLM Model** | Claude Sonnet 4 |
| **Priority** | 🔴 Critical |

### Integration

| System | Integration Type | Purpose |
|--------|------------------|---------|
| **AWS SDK** | Direct API | Resource management |
| **GitHub Issues** | A2A Protocol | Task assignment |
| **miyabi-orchestrator** | Rust API | Coordination |
| **CloudWatch** | Monitoring | Metrics & Logs |

---

## 🏗️ Architecture

### High-Level Design

```
┌────────────────────────────────────────────────────────┐
│                    CoordinatorAgent                    │
│                                                        │
│  Issue: "Deploy Lambda function for API endpoint"     │
└───────────────────────┬────────────────────────────────┘
                        │
                        ▼
┌────────────────────────────────────────────────────────┐
│                     AWSAgent (301)                     │
│                                                        │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐ │
│  │ Multi-Account│  │  Resource    │  │  Service    │ │
│  │  Manager     │  │  Manager     │  │  Agent      │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬──────┘ │
│         │                 │                  │        │
└─────────┼─────────────────┼──────────────────┼────────┘
          │                 │                  │
          ▼                 ▼                  ▼
┌─────────────────────────────────────────────────────────┐
│                   AWS Multi-Account                     │
│                                                         │
│  Management Account (Zeus)                              │
│      ├── Production Account (Apollo)                    │
│      │     ├── EC2, Lambda, S3, RDS                     │
│      │     └── Managed by Historical Agents             │
│      ├── Security Account (Cerberus)                    │
│      │     └── GuardDuty, Security Hub                  │
│      └── Development Account (Athena)                   │
│            └── Test Resources                           │
└─────────────────────────────────────────────────────────┘
```

### Component Breakdown

#### 1. Multi-Account Manager
**Responsibility**: AWS Organizations & Cross-account access

**Features**:
- Assume cross-account roles
- Organization-wide resource discovery
- Consolidated billing analysis
- Account lifecycle management

#### 2. Resource Manager
**Responsibility**: CRUD operations for AWS resources

**Supported Services**:
- **Compute**: EC2, Lambda, ECS Fargate
- **Storage**: S3, EBS, EFS
- **Database**: RDS, DynamoDB, Aurora
- **Network**: VPC, CloudFront, Route 53
- **IaC**: CloudFormation, CDK

#### 3. Service Agent Manager
**Responsibility**: Service-as-Agent model implementation

**Features**:
- Map AWS service → Historical Agent
- Manage service dependencies
- Autonomous decision-making per service
- Real-time state synchronization

---

## 🔑 Core Types

### Rust Data Models

```rust
// crates/miyabi-aws-agent/src/types.rs
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// AWS Account representation
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AwsAccount {
    pub id: String,
    pub name: String,
    pub role: AccountRole,
    pub region: String,
    pub credentials: AwsCredentials,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum AccountRole {
    Management,
    Production,
    Security,
    Development,
}

/// AWS Resource representation
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AwsResource {
    pub id: String,
    pub arn: String,
    pub resource_type: AwsResourceType,
    pub region: String,
    pub account_id: String,
    pub state: ResourceState,
    pub owner_agent: HistoricalAgent,
    pub dependencies: Vec<String>,
    pub tags: HashMap<String, String>,
    pub metadata: serde_json::Value,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum AwsResourceType {
    Ec2Instance,
    S3Bucket,
    LambdaFunction,
    RdsInstance,
    DynamoDbTable,
    CloudFormationStack,
    VpcNetwork,
    CloudFrontDistribution,
    ApiGateway,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ResourceState {
    Creating,
    Active,
    Updating,
    Deleting,
    Failed,
    Terminated,
}

/// Service Agent representation
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ServiceAgent {
    pub name: String,
    pub service_type: AwsResourceType,
    pub dependencies: Vec<String>,
    pub state: ResourceState,
    pub autonomy_level: u8,
    pub decision_maker: HistoricalAgent,
    pub cost_per_day: f64,
    pub health_status: HealthStatus,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum HistoricalAgent {
    BillGates,      // EC2, Lambda (compute)
    SteveJobs,      // CloudFront, S3 (frontend)
    Napoleon,       // Auto Scaling, Load Balancer (strategy)
    Hannibal,       // Lambda@Edge, CloudFront Functions (tactics)
    Drucker,        // CloudWatch, X-Ray (management)
    Kotler,         // API Gateway, SNS (marketing/communication)
    Noguchi,        // RDS, DynamoDB (research data)
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum HealthStatus {
    Healthy,
    Degraded,
    Unhealthy,
    Unknown,
}

/// AWS Agent Task
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AwsTask {
    pub id: String,
    pub task_type: AwsTaskType,
    pub resource_type: AwsResourceType,
    pub account_id: String,
    pub region: String,
    pub parameters: HashMap<String, serde_json::Value>,
    pub dependencies: Vec<String>,
    pub assigned_agent: HistoricalAgent,
    pub status: TaskStatus,
    pub created_at: DateTime<Utc>,
    pub completed_at: Option<DateTime<Utc>>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum AwsTaskType {
    CreateResource,
    UpdateResource,
    DeleteResource,
    DiscoverResources,
    OptimizeCosts,
    SecurityAudit,
    HealthCheck,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum TaskStatus {
    Pending,
    InProgress,
    Completed,
    Failed,
    Cancelled,
}
```

---

## 🤖 Agent Workflow

### 1. Task Reception

```
GitHub Issue Created/Labeled
    ↓
CoordinatorAgent parses Issue
    ↓
Determines AWS task required
    ↓
Assigns to AWSAgent (301)
```

### 2. Task Analysis

```rust
impl AWSAgent {
    async fn analyze_task(&self, issue: &Issue) -> Result<AwsTask> {
        // 1. Parse Issue body
        let task_description = self.parse_issue_body(&issue.body)?;

        // 2. Identify resource type
        let resource_type = self.identify_resource_type(&task_description)?;

        // 3. Determine operation (Create/Update/Delete)
        let operation = self.determine_operation(&task_description)?;

        // 4. Extract parameters
        let params = self.extract_parameters(&task_description)?;

        // 5. Assign to Historical Agent
        let assigned_agent = self.assign_historical_agent(&resource_type)?;

        Ok(AwsTask {
            task_type: operation,
            resource_type,
            assigned_agent,
            parameters: params,
            ..Default::default()
        })
    }
}
```

### 3. Resource Management Execution

```rust
impl AWSAgent {
    async fn execute_task(&self, task: AwsTask) -> Result<ExecutionResult> {
        match task.task_type {
            AwsTaskType::CreateResource => {
                self.create_resource(task).await?
            }
            AwsTaskType::UpdateResource => {
                self.update_resource(task).await?
            }
            AwsTaskType::DeleteResource => {
                self.delete_resource(task).await?
            }
            AwsTaskType::DiscoverResources => {
                self.discover_resources(task).await?
            }
            AwsTaskType::OptimizeCosts => {
                self.optimize_costs(task).await?
            }
            _ => Err(AgentError::UnsupportedTaskType),
        }
    }

    async fn create_resource(&self, task: AwsTask) -> Result<AwsResource> {
        // 1. Authenticate to AWS account
        let client = self.get_aws_client(&task.account_id, &task.region).await?;

        // 2. Check dependencies
        self.verify_dependencies(&task.dependencies).await?;

        // 3. Execute AWS API call
        let resource = match task.resource_type {
            AwsResourceType::Ec2Instance => {
                self.create_ec2_instance(&client, &task.parameters).await?
            }
            AwsResourceType::LambdaFunction => {
                self.create_lambda_function(&client, &task.parameters).await?
            }
            AwsResourceType::S3Bucket => {
                self.create_s3_bucket(&client, &task.parameters).await?
            }
            _ => return Err(AgentError::UnsupportedResourceType),
        };

        // 4. Tag resource with Historical Agent
        self.tag_resource(&resource, &task.assigned_agent).await?;

        // 5. Register as Service Agent
        self.register_service_agent(&resource).await?;

        Ok(resource)
    }
}
```

### 4. Service-as-Agent Model

```rust
impl AWSAgent {
    async fn register_service_agent(&self, resource: &AwsResource) -> Result<ServiceAgent> {
        let service_agent = ServiceAgent {
            name: resource.id.clone(),
            service_type: resource.resource_type.clone(),
            dependencies: resource.dependencies.clone(),
            state: resource.state.clone(),
            autonomy_level: self.calculate_autonomy_level(&resource)?,
            decision_maker: resource.owner_agent.clone(),
            cost_per_day: self.estimate_daily_cost(&resource).await?,
            health_status: HealthStatus::Unknown,
        };

        // Store in miyabi-composite-state
        self.state_manager.register_service_agent(service_agent).await?;

        Ok(service_agent)
    }

    fn calculate_autonomy_level(&self, resource: &AwsResource) -> Result<u8> {
        // Autonomy level based on resource type and configuration
        match resource.resource_type {
            AwsResourceType::LambdaFunction => Ok(8),  // High autonomy
            AwsResourceType::Ec2Instance => Ok(6),     // Medium autonomy
            AwsResourceType::RdsInstance => Ok(4),     // Low autonomy (stateful)
            _ => Ok(5),
        }
    }
}
```

### 5. Monitoring & Health Check

```rust
impl AWSAgent {
    async fn monitor_resources(&self) -> Result<()> {
        let resources = self.get_all_managed_resources().await?;

        for resource in resources {
            let health = self.check_resource_health(&resource).await?;

            if health != HealthStatus::Healthy {
                self.alert(&resource, health).await?;

                if self.should_auto_heal(&resource) {
                    self.auto_heal(&resource).await?;
                }
            }

            // Update state
            self.update_resource_state(&resource, health).await?;
        }

        Ok(())
    }

    async fn check_resource_health(&self, resource: &AwsResource) -> Result<HealthStatus> {
        match resource.resource_type {
            AwsResourceType::Ec2Instance => {
                self.check_ec2_health(resource).await
            }
            AwsResourceType::LambdaFunction => {
                self.check_lambda_health(resource).await
            }
            _ => Ok(HealthStatus::Unknown),
        }
    }
}
```

---

## 🔒 Security & Compliance

### IAM Role Configuration

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances",
        "s3:ListBucket",
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "lambda:CreateFunction",
        "lambda:UpdateFunctionCode",
        "lambda:DeleteFunction",
        "rds:DescribeDBInstances",
        "rds:CreateDBInstance",
        "rds:DeleteDBInstance"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "arn:aws:iam::*:role/MiyabiAgentRole"
    }
  ]
}
```

### Security Best Practices

1. **Least Privilege**: Only grant necessary permissions
2. **Role Assumption**: Use temporary credentials via STS
3. **Audit Logging**: All AWS API calls logged to CloudTrail
4. **Resource Tagging**: Tag all resources with `MiyabiManaged=true`
5. **Cost Alerts**: Set billing alerts for unexpected charges

---

## 📊 Integration with Pantheon Society

### Historical Agent Assignment Rules

```rust
impl AWSAgent {
    fn assign_historical_agent(&self, resource_type: &AwsResourceType) -> HistoricalAgent {
        match resource_type {
            // Compute (Bill Gates)
            AwsResourceType::Ec2Instance => HistoricalAgent::BillGates,
            AwsResourceType::LambdaFunction => HistoricalAgent::BillGates,

            // Frontend/CDN (Steve Jobs)
            AwsResourceType::CloudFrontDistribution => HistoricalAgent::SteveJobs,
            AwsResourceType::S3Bucket => HistoricalAgent::SteveJobs,

            // Scaling/Strategy (Napoleon)
            AwsResourceType::AutoScalingGroup => HistoricalAgent::Napoleon,
            AwsResourceType::LoadBalancer => HistoricalAgent::Napoleon,

            // Edge Computing (Hannibal)
            AwsResourceType::LambdaEdge => HistoricalAgent::Hannibal,

            // Monitoring/Management (Drucker)
            AwsResourceType::CloudWatch => HistoricalAgent::Drucker,
            AwsResourceType::XRay => HistoricalAgent::Drucker,

            // API/Communication (Kotler)
            AwsResourceType::ApiGateway => HistoricalAgent::Kotler,
            AwsResourceType::SNS => HistoricalAgent::Kotler,

            // Data/Research (Noguchi)
            AwsResourceType::RdsInstance => HistoricalAgent::Noguchi,
            AwsResourceType::DynamoDbTable => HistoricalAgent::Noguchi,

            _ => HistoricalAgent::BillGates, // Default
        }
    }
}
```

### Mythological Guardian Integration

#### Cerberus (Security)
- Monitors all AWS resource creation
- Enforces security group rules
- Blocks suspicious activity

#### Michael (Ethics)
- Ensures cost optimization
- Reviews resource necessity
- Enforces tagging compliance

#### Buddha (Harmony)
- Balances resource allocation
- Prevents over-provisioning
- Maintains system equilibrium

---

## 📈 Cost Optimization

### Auto-Optimization Features

```rust
impl AWSAgent {
    async fn optimize_costs(&self) -> Result<CostReport> {
        let mut savings = 0.0;

        // 1. Stop idle EC2 instances
        let idle_instances = self.find_idle_ec2_instances().await?;
        for instance in idle_instances {
            self.stop_instance(&instance).await?;
            savings += self.calculate_savings(&instance);
        }

        // 2. Delete unused S3 buckets
        let unused_buckets = self.find_unused_s3_buckets().await?;
        for bucket in unused_buckets {
            self.delete_bucket(&bucket).await?;
            savings += self.calculate_savings(&bucket);
        }

        // 3. Right-size RDS instances
        let oversized_rds = self.find_oversized_rds_instances().await?;
        for instance in oversized_rds {
            self.resize_rds_instance(&instance).await?;
            savings += self.calculate_savings(&instance);
        }

        // 4. Enable S3 Intelligent-Tiering
        self.enable_s3_intelligent_tiering().await?;

        Ok(CostReport {
            total_savings: savings,
            optimizations: vec![...],
            recommendations: vec![...],
        })
    }
}
```

---

## 🧪 Testing Strategy

### Unit Tests

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_create_ec2_instance() {
        let agent = AWSAgent::new_test();
        let task = AwsTask {
            task_type: AwsTaskType::CreateResource,
            resource_type: AwsResourceType::Ec2Instance,
            parameters: hashmap! {
                "instance_type".to_string() => json!("t3.micro"),
                "ami_id".to_string() => json!("ami-12345678"),
            },
            ..Default::default()
        };

        let result = agent.create_resource(task).await;
        assert!(result.is_ok());
    }

    #[tokio::test]
    async fn test_assign_historical_agent() {
        let agent = AWSAgent::new_test();
        let assigned = agent.assign_historical_agent(&AwsResourceType::Ec2Instance);
        assert_eq!(assigned, HistoricalAgent::BillGates);
    }
}
```

### Integration Tests

```rust
#[tokio::test]
async fn test_end_to_end_lambda_deployment() {
    // 1. Create Issue
    let issue = create_test_issue("Deploy Lambda function for API");

    // 2. AWSAgent processes Issue
    let agent = AWSAgent::new();
    let task = agent.analyze_task(&issue).await.unwrap();

    // 3. Execute task
    let result = agent.execute_task(task).await.unwrap();

    // 4. Verify Lambda exists in AWS
    assert!(result.state == ResourceState::Active);

    // 5. Verify Service Agent registered
    let service_agent = agent.get_service_agent(&result.id).await.unwrap();
    assert_eq!(service_agent.decision_maker, HistoricalAgent::BillGates);
}
```

---

## 📚 Dependencies

### Cargo.toml

```toml
[package]
name = "miyabi-aws-agent"
version = "0.1.0"
edition = "2021"

[dependencies]
aws-config = "1.5"
aws-sdk-ec2 = "1.50"
aws-sdk-s3 = "1.52"
aws-sdk-lambda = "1.48"
aws-sdk-rds = "1.49"
aws-sdk-dynamodb = "1.46"
aws-sdk-cloudformation = "1.47"
aws-sdk-sts = "1.44"

tokio = { version = "1.40", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
chrono = { version = "0.4", features = ["serde"] }
anyhow = "1.0"
thiserror = "2.0"

# Miyabi crates
miyabi-types = { path = "../miyabi-types" }
miyabi-agent-core = { path = "../miyabi-agent-core" }
miyabi-composite-state = { path = "../miyabi-composite-state" }

[dev-dependencies]
tokio-test = "0.4"
```

---

## 📊 Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Resource Creation Time | <5s | AWS API response time |
| Cost Optimization | -30% | Cost Explorer |
| Resource Health Check | 100% coverage | CloudWatch metrics |
| Security Compliance | 100% | AWS Config |
| Agent Autonomy Level | >7/10 | Service Agent metrics |

---

## 🔗 Related Documentation

### Miyabi Core
- `.claude/context/agents.md`
- `.claude/context/architecture.md`
- `crates/miyabi-agent-core/`

### Pantheon Society
- `.claude/context/pantheon-society.md`
- `.ai/plans/pantheon-webapp-aws-deployment.md`
- `.ai/plans/THE_PANTHEON_REQUIREMENTS.md`

### AWS
- AWS SDK for Rust: https://docs.aws.amazon.com/sdk-for-rust/
- AWS Well-Architected Framework
- AWS Organizations Best Practices

---

## 🎯 Implementation Checklist

### Phase 1: Foundation (Week 1)
- [ ] Create `miyabi-aws-agent` crate
- [ ] Define core types (`AwsResource`, `ServiceAgent`)
- [ ] Implement multi-account authentication
- [ ] Setup IAM roles

### Phase 2: Resource Management (Week 2)
- [ ] EC2 management (create/stop/terminate)
- [ ] S3 management (create/delete/upload)
- [ ] Lambda management (create/update/delete)
- [ ] RDS management (create/delete)

### Phase 3: Service-as-Agent (Week 3)
- [ ] Historical agent assignment logic
- [ ] Service agent registration
- [ ] Dependency graph management
- [ ] Autonomy level calculation

### Phase 4: Monitoring & Optimization (Week 4)
- [ ] Health check implementation
- [ ] Cost optimization features
- [ ] Auto-healing mechanisms
- [ ] CloudWatch integration

### Phase 5: Testing & Documentation (Week 5)
- [ ] Unit tests (>80% coverage)
- [ ] Integration tests
- [ ] E2E tests with real AWS account
- [ ] API documentation

---

**Status**: 🟢 Specification Complete - Ready for Implementation

**Next Steps**:
1. Review specification with team
2. Create GitHub Issue (#PANTHEON-AWS-001)
3. Begin Phase 1 implementation
4. Setup AWS test account

**Last Updated**: 2025-11-12
**Maintained By**: Miyabi Team
**Contact**: Through Miyabi framework
