# E-Voting Application
sample text
## Data on Server
___
1. Permanent
   1. Voter / Device ID
   2. PIN
2. Temporary
   1. Authentication Tokens
   2. Master Token (Created server-side using seperate auth tokens)
   3. Vote cast

## Process
___
1. System Authentication
2. Voter Login using Voter ID / Device ID and PIN - Session lasts for short duration
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
___
```
{
   "prompt": string,
   "options": string[]
}
```
## Authentication
___
1. ### Methods (Selectable)
   1. System Authentication (Device Auth)
   2. Government Authentication
   3. On-Device TOTP Authentication
   4. Voter ID Card/Secondary Device TOTP Authentication
2. ### API
   1. Initial Verification Authorization
      1. Request Example
         ```
         POST /cgi-bin/process.cgi HTTP/1.1
         {
            "id": string,
            "pin": int
         }
         ```
      2. Response Example
         ```
         {
            "auth_token": string,
            "expiry": date
         }
         ```
   2. Standard Auth
      1. Request Example
         ```
         POST /cgi-bin/process.cgi HTTP/1.1
         Authorization: Basic <credentials>
         {
            "auth_type": int,
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
   3. Final Form Auth
      1. Request Example
         ```
         POST /cgi-bin/process.cgi HTTP/1.1
         Authorization: Basic <credentials>
         {
            "gen_token": string,
            "form_data": string
         }
         ```
      2. Response Example
         ```
         {
            "vote_status": int,
            "message": string
         }
         ```
## Table Structure
___
| Device/Voter ID    | Pin     |
| ------------------ | ------- |
| 234234234234324324 | 3242333 |
| 234234234234234234 | 3323453 |

## Todo
___
1. Client
   - [ ] System Authentication
     - [ ] Basic
     - [ ] Proper
   - [ ] Login
     - [ ] Interface
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