Core Application - 6 Server Deployment

Project Overview
Migration of 6 CCB (Core) application servers from on-premises to OCI Dubai region.

Business Objectives

High Availability: 99.9% uptime SLA
Performance: 40% improvement target
Security: Financial services compliance
Cost: 30% reduction vs on-premises

Architecture Design

Source Environment (On-Premises)
Architecture Design
Source Environment (On-Premises)
On-Premises Setup: ├── CCB-App-01 to CCB-App-06 
├── Load Balancer (Hardware) 
├── Shared Storage (ODA) 
└── Database Connectivity

Target Environment (OCI Dubai)
OCI Dubai Architecture: ├── Application Tier 
│ ├── CCB-App-01 (....) 
│ ├── CCB-App-02 (....) 
│ ├── CCB-App-03 (....) 
│ ├── CCB-App-04 (....) 
│ ├── CCB-App-05 (....) 
│ └── CCB-App-06 (....) 
├── Load Balancer (OCI LB) 
├── Network Security Groups 
└── Monitoring & Alerting
