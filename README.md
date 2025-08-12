# Introduction

This repo will combine [Containerlab](https://containerlab.dev/) and [EDA (Event-Driven Automation)](https://docs.eda.dev/25.4/) to deploy the Data Center Fabric topology requested by Pan Dacom. To integrate the Containerlab topology seamlessly within EDA, you can use [EDA Clab-Connector](https://github.com/eda-labs/clab-connector).

There are different files that are located in the repo:
  - *pan-dacom.yml:* Declarative file which contains the lab topology that will be deployed using Containerlab. There are 2 Data Centers in this deployment, each one with 2 Leaves and 2 Spines forming a CLOS topology. Spines from each Data Center are connected back-to-back between dark fiber.
  - *configs folder:* Contains the startup confgiguration for all Linux clients connected to each Leaf of both Data Centers.
  - *eda-files folder:* Contains different subfolders which map each EDA application that needs to be configured manually.

# Lab deployment

As mentioned earlier, the lab relies on the installation of [Containerlab](https://containerlab.dev/install/) and [EDA](https://docs.eda.dev/25.4/getting-started/try-eda/) on the server/virtual machine where the lab will be deployed. To be able to manage Containerlab nodes within EDA, a trial license will be required. Get in touch with your proper Nokia contact to obtain it.

Apart from them, follow the [EDA Clab-Connector README](https://github.com/eda-labs/clab-connector) to get this tool installed as well. We will use it to seamlessly onboard into EDA the nodes deployed by Containerlab.

After all tools have been installed, let's start by deploying the Containerlab topology:

```
clab deploy -t pan-dacom.yml
```

The lab deployment should be ready in few minutes, so you can SSH into the nodes. However, they don't have any startup configuration, so they will be empty. Let's onboard all nodes into EDA by running the following command (replace "EDA-IP" and "parent-path" by your own values):

```
clab-connector integrate --eda-url https://<EDA-IP>:9443 -t <parent-path>/clab-pan-dacom/topology-data.json
```

At this stage, EDA has become the source of truth of the network as it is now managing all nodes from both fabrics (yes, with only one instance). Now, it's time to copy-paste the declarative YAML files from *eda-files* folder into your EDA application. For doing that, log into EDA with the deafult credentials and navigate into *clab-pan-dacom* namespace before copy-pasting the following files:
1. First of all, let's copy-paste the **Allocations** folder. No matter the order you follow within this folder but you will see that some of the files are already in place, due to clab-connector tool has created them. Replace the content of the original files for the one that appears in this repo, as it contains some resource reservations that will be taken into account later.
2. Secondly, copy-paste the **Fabrics** folder. After that, underlay eBGP IPv4 sessions and overlay iBGP EVPN sessions will be established across all nodes within the specific sites. So, the next step will be to establish BGP sessions to interconnect both Data Centers.
3. Now copy-paste the **Default Routing** folder. In this case, we will need to create **Default Interfaces** on the first hand, then **Default BGP Groups** and later **Default BGP Peers**. We need to follow this order due to *Default BGP Peers* has references to the previous folders.
4. Lastly, copy-paste the **Virtual Networks** folder. It contains an example of an extended L2 service across both Data Centers, which is connected to an IP-VRF with the same IRB (Anycast GW) on all Leaves, so they can use the same default GW in case the clients are moved to another Leaf.

After all EDA declarative files have been configured, the lab environment is ready to be tested. Let's log into one of the clients and start pinging the remaining ones, on both Data Centers (example from *client1-dc1*):

```
docker exec -it client1-dc1 bash
ping 192.168.0.12   # Ping to client2-dc1
ping 192.168.0.21   # Ping to client1-dc2
ping 192.168.0.22   # Ping to client2-dc2
```
