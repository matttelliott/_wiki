---
created: 2025-08-18
modified: 2025-08-18
type: project
status: active
tags: [project, homelab, nas, networking, self-hosting, infrastructure]
due: 
priority: medium
area: Technology & Infrastructure
---

# Home Network Infrastructure: NAS & Self-Hosted Services

## 🎯 Project Purpose
*Why am I doing this project? What problem does it solve?*

Create a robust, self-hosted home infrastructure that provides reliable storage, backup, and media services while learning networking fundamentals. This solves the problems of data sovereignty, cloud service dependencies, subscription costs, and provides a learning platform for system administration and networking skills. The goal is to transform semi-functional hardware into a cohesive home datacenter that serves both practical needs and technical education.

## ✨ Desired Outcome
*What does "done" look like? How will I know when this project is complete?*

A fully functional home network with the Synology NAS providing reliable storage and the Mac Mini hosting Docker services, all accessible securely from inside and outside the home network. The system should be stable enough for family use, documented well enough to troubleshoot issues, and expandable for future services.

### Success Criteria
- [ ] Synology NAS properly configured for file storage and backups
- [ ] Mac Mini running stable Docker containers for all services
- [ ] Reliable external access via VPN or reverse proxy
- [ ] Automated backups for all personal data and git repositories
- [ ] Jellyfin serving media library smoothly
- [ ] Gitea providing private git hosting
- [ ] ArchiveBox capturing and preserving web content
- [ ] Nextcloud syncing files across devices
- [ ] Network properly segmented and secured
- [ ] Documentation complete for maintenance and recovery
- [ ] Monitoring and alerting for service health

## 📋 Project Planning

### Brainstorm
*All ideas, thoughts, and possibilities related to this project*
- Use Mac Mini as compute, Synology as storage (separation of concerns)
- Implement VLAN segmentation for IoT, guest, and server networks
- Set up Tailscale or WireGuard for secure remote access
- Use Traefik or Nginx Proxy Manager for reverse proxy
- Implement 3-2-1 backup strategy (3 copies, 2 different media, 1 offsite)
- Add Prometheus + Grafana for monitoring
- Set up Portainer for Docker management
- Implement Authentik or Authelia for single sign-on
- Add Home Assistant for home automation
- Create automated backup to cloud (encrypted)
- Set up DNS sinkhole with Pi-hole or AdGuard
- Implement proper SSL certificates with Let's Encrypt
- Add Vaultwarden for password management
- Create network diagram and documentation
- Set up UPS for power protection

### Project Components
*Major pieces or phases of the project*

1. **Network Foundation**
   - Document current network topology
   - Plan IP addressing scheme
   - Configure VLANs if router supports
   - Set up static IPs for servers
   - Configure firewall rules
   - Implement secure remote access solution

2. **Synology NAS Optimization**
   - Audit current configuration
   - Set up proper RAID configuration
   - Create shared folders with appropriate permissions
   - Configure automated backups
   - Set up NFS/SMB shares for Mac Mini
   - Enable and secure SSH access
   - Configure snapshot schedules

3. **Mac Mini Docker Host Setup**
   - Install Docker and Docker Compose
   - Set up Portainer for management
   - Configure storage mounts to NAS
   - Create Docker networks
   - Set up reverse proxy (Traefik/NPM)
   - Implement SSL certificates

4. **Core Services Deployment**
   - **Jellyfin**: Media server setup with hardware transcoding
   - **Gitea**: Git hosting with CI/CD runners
   - **Nextcloud**: File sync with office suite
   - **ArchiveBox**: Web archival system

5. **Security & Access**
   - VPN server (Tailscale/WireGuard)
   - Reverse proxy with SSL
   - Authentication gateway (Authentik/Authelia)
   - Firewall hardening
   - Regular security updates automation

6. **Monitoring & Maintenance**
   - Health checks for all services
   - Automated backups verification
   - Resource usage monitoring
   - Alert system for failures
   - Documentation wiki

### Resources Needed
- **People:** r/selfhosted community, r/homelab community
- **Tools:** Docker, Docker Compose, SSH clients, network tools
- **Information:** Service documentation, networking tutorials, security best practices
- **Budget:** Potential costs for domain name (~$12/year), cloud backup storage

### Constraints & Risks
- **Constraints:** Limited networking knowledge, ISP restrictions, upload bandwidth
- **Risks:** Data loss during migration, security breaches, service downtime affecting family
- **Dependencies:** Internet stability, hardware reliability, power availability

## ✅ Next Actions
*Immediate next physical actions to move this project forward*
- [ ] Document current network setup and IP assignments #@computer
- [ ] SSH into Synology and audit current Docker setup #@computer
- [ ] List all services currently running and their status #@computer
- [ ] Test current external access method and document issues #@computer
- [ ] Research Mac Mini Docker installation best practices #@computer
- [ ] Create network diagram of current setup #@computer
- [ ] Backup all current configurations before changes #@computer

## ⏳ Waiting For
*Items delegated or waiting on others*
- [ ] Family agreement on downtime windows for migration
- [ ] ISP information about static IP availability
- [ ] Hardware (consider getting UPS for power protection)

## 📊 Milestones
- [ ] **Milestone 1:** Network documented and optimized - Target: Week 1-2
- [ ] **Milestone 2:** Mac Mini Docker environment ready - Target: Week 3-4
- [ ] **Milestone 3:** Core services migrated and stable - Target: Week 5-6
- [ ] **Milestone 4:** Remote access working reliably - Target: Week 7-8
- [ ] **Milestone 5:** Monitoring and backups automated - Target: Week 9-10

## 📝 Project Notes
*Meeting notes, research, decisions, and other project-related information*

### Current Setup Assessment
**Synology NAS:**
- Model: [To be documented]
- Current services: Docker containers (partially working)
- Storage capacity: [To be documented]
- RAID configuration: [To be documented]
- Issues: Services not fully functional, external access unreliable

**Mac Mini:**
- Model: [To be documented]
- OS version: [To be documented]
- Available storage: [To be documented]
- Current use: [To be documented]
- Potential: Docker host for compute-intensive services

**Network:**
- Router model: [To be documented]
- ISP: [To be documented]
- External access method: [Current method, issues]
- Internal subnet: [To be documented]

### Architecture Decisions
- **Separation of Concerns:** NAS for storage, Mac Mini for compute
- **Container Strategy:** All services in Docker for portability
- **Backup Philosophy:** Automated, tested, offsite copies
- **Security Stance:** Zero trust, defense in depth
- **Access Method:** VPN preferred over port forwarding

### Service Priority
1. **Critical:** File storage, backups, git repositories
2. **Important:** Media server (Jellyfin), file sync (Nextcloud)
3. **Nice to Have:** Web archiving, additional services

### Learning Goals
- Understand VLANs and network segmentation
- Master Docker orchestration
- Learn reverse proxy and SSL management
- Understand backup strategies and implementation
- Gain experience with monitoring and logging

### Useful Resources
- [Awesome-Selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted)
- [TechnoTim YouTube](https://www.youtube.com/c/TechnoTimLive)
- [r/selfhosted Wiki](https://www.reddit.com/r/selfhosted/wiki)
- Docker documentation
- Synology DSM documentation
- Service-specific documentation (Jellyfin, Gitea, etc.)

### Security Considerations
- Change all default passwords
- Use SSH keys instead of passwords
- Enable 2FA where possible
- Regular security updates
- Backup encryption for sensitive data
- Network segmentation for IoT devices
- Regular security audits

## 📎 Supporting Materials
*Links to relevant documents, files, and resources*
- [[Network Diagram]]
- [[Service Configuration Notes]]
- [[Backup Strategy]]
- [[Security Checklist]]
- Docker Compose files repository
- Configuration backup location

## 📈 Project Updates
### 2025-08-18
*Initial project documentation. Current setup is partially functional with Synology NAS running some Docker containers but experiencing issues. Mac Mini identified as potential Docker host. Need to learn networking basics and properly architect the solution. Focus on stability and documentation.*

---
**Project Review Schedule:** Weekly on Saturdays
**Next Review:** [[2025-08-24]]