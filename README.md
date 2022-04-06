# E-Voting Application
sample text

## Tools Intended to be Used in Deployment
- Flutter + Android Studio
- Redis
- Node + React
- Python + Flask + Brownie
- Solidity
## Data on Server
1. Permanent
   1. Private Blockchain
      1. ID
      2. PIN
2. Temporary
   1. Authentication Tokens
   2. Master Token (Created server-side using seperate auth tokens)
   3. Vote cast

## Process
1. System Authentication
2. Login using ID and PIN - Session lasts for short duration (5 minutes?)
3. Server creates key pair and sends public key to client on login
4. Go through all selected authentications using API to generate a tokens
5. Fetch and show voting form
6. Server and client creates master token using all auth tokens and timestamp
7. Send result with master token for validation encrypted with the key
   1. If fails, validate authenticity
      1. If reasonably valid attempt - Connect with Fail Support
      2. Else - Fail prompt
   2. If succeeds, send confirmation
8. Delete all session data

## Voting Form JSON Structure
```
{
   "prompt": string,
   "options": string[]
}
```
## Authentication
1. ### Methods (Selectable)
   1. System Authentication (Device Auth)
   2. Secondary ID Authentication (Unique Verifiable ID Ex. Govt ID)
   3. On-Device TOTP Authentication (Phone)
   4. Secondary Device TOTP Authentication (Voter Card, Other Device, etc.)
2. ### API
   1. Login
      1. Request Example
         ```
         POST /cgi-bin/process.cgi HTTP/1.1
         {
            "id": string,
            "pin": string
         }
         ```
      2. Response Example
         ```
         {
            "jwt": string,
            "req_methods": string[],
            "enc_key": string,
            "expiry": date
         }
         ```
   2. Standard Auth
      1. Request Example
         ```
         POST /cgi-bin/process.cgi HTTP/1.1
         Authorization: Bearer <jwt>
         {
            "auth_type": string,
            "auth_key": string
         }
         ``` 
      2. Response Example
         ```
         {
            "token": string,
            "expiry": date
         }
         ```
   3. Submit Form Auth
      1. Request Example
         ```
         POST /cgi-bin/process.cgi HTTP/1.1
         Authorization: Bearer <jwt>
         {
            "master_token": string,
            "form_option": string
         }
         ```
      2. Response Example
         ```
         {
            "vote_status": string,
            "message": string
         }
         ```
   4. Fail Example
      ```
      {
         "error_type": string,
         "message": string
      }
      ```
## Table Structure
| Some ID            | Pin     |
| ------------------ | ------- |
| 234234234234324324 | 3242333 |
| 234234234234234234 | 3323453 |

## Todo
1. Client
   - [x] System Authentication
     - [x] Basic
     - [x] Proper
   - [ ] Login
     - [x] Interface
     - [ ] Implementation
   - [ ] Main Authentication
     - [ ] Interface
       - [ ] On-Device TOTP
       - [ ] Secondary TOTP
       - [ ] Government Auth
     - [ ] Functionality
       - [ ] On-Device TOTP
       - [ ] Secondary TOTP
       - [ ] Government Auth
   - [ ] Vote Form
     - [ ] Interface
     - [ ] Fetch
   - [ ] Security
     - [ ] Encryption
     - [ ] TLS
   - [ ] Prettification
2. Server
   - [ ] Request Handling
     - [ ] Login
     - [ ] Authentication
       - [ ] On-Device TOTP
       - [ ] Secondary TOTP
       - [ ] Government Auth
     - [ ] Voting
       - [ ] Form
       - [ ] Submission
     - [ ] Vote Management
   - [ ] Blokchain
     - [ ] Count votes
     - [ ] Store Registered IDs
   - [ ] Security
     - [ ] Session Key Pairs
     - [ ] TLS
     - [ ] Secure Network
3. Vote Management
   - [ ] Homepage
     - [ ] Results
     - [ ] Status
   - [ ] Voting
     - [ ] Configure
     - [ ] Start Vote
     - [ ] End Vote
   - [ ] Security
     - [ ] Same Network
     - [ ] TLS


<details>
   <summary>???</summary>
   1. https://cs.brown.edu/research/pubs/theses/capstones/2019/polshakova.nina.pdf
   2. 
</details>