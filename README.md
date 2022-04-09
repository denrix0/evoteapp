# E-Voting Application
sample text

## Tools Intended to be Used in Deployment
- Flutter + Android Studio
- MongoDB + PostgreSQL
- Node + React
- Python + Flask + Brownie + Gunicorn
- Solidity
## Data on Server
1. Permanent
   1. Private Blockchain
      1. Vote Count
      2. Authorized Nodes
   2. SQL (User Data)
      1. Id
      2. PIN
      3. Salt
      4. TOTP 1 Secret
      5. TOTP 2 Secret
2. Temporary
   1. Authentication Tokens
   2. Master Token
   3. Key Pair

## Specifications
1. Authorization : JWT
   ```
   {
      "alg": "HS512",
      "exp": <Expiry>,
   }
   ```
2. PIN : 8-64 Digits
3. Key Pair : Ed25519
4. Auth Tokens : Random 256-bit URL-Safe Base64 Strings
5. Master Token : SHA Hash of concatenated tokens seperated by '.'

## Process

1. Creating a User
   1. Add TOTP secret to devices
   2. Store ID, PIN, TOTP secrets in SQL DB
2. Voting
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

## Authentication
1. ### Methods (Selectable)
   1. System Authentication (Device Auth)
   2. Secondary ID Authentication (Unique Verifiable ID, Ex. Govt ID)
   3. On-Device TOTP Authentication (Phone)
   4. Secondary Device TOTP Authentication (Any Device)
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
            "expiry": int
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
            "expiry": int
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
## Data Structures
### MySQL
user_details table
| Some ID            | Pin     | TOTP 1 | TOTP 2 |
| ------------------ | ------- | ------ | ------ |
| 234234234234324324 | 3242333 | 213123 | 213123 |
| 234234234234234234 | 3323453 | 213123 | 213123 |

### MongoDB
1. User data
   ```
   <User ID>: {
      'auth_tokens': {
         <Method Name> : <Token>,
         ...
      },
      'master_token': <Token>,
      'key_pair': {
         'pub': <Public Key>,
         'pvt': <Private Key>
      }
   }
   ```

2. Voting Config & Form
   ```
   "voting_form": {
      "prompt": <Poll Prompt>,
      "options": [<Options>]
   }

   "vote_config": {
      "req_methods": [<Selected Methods>],
      "expiry": <Duartion>
   }

   ```
   > Method Names: "uid", "totp1", "totp2"

   > Expiry Default: 600 seconds

## Todo
<details>
   <summary>Expand</summary>

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
     - [x] Login
     - [ ] Authentication
       - [ ] On-Device TOTP
       - [ ] Secondary TOTP
       - [ ] Government Auth
     - [ ] Voting
       - [x] Form
       - [ ] Submission
     - [ ] Vote Management
   - [ ] Blokchain
     - [ ] Count votes
     - [ ] Handle Nodes
   - [ ] Security
     - [ ] Session Key Pairs
     - [ ] TLS
     - [ ] Hash & Salt PIN
3. Vote Management
   - [ ] Homepage
     - [ ] Results
     - [ ] Status
     - [ ] Add Users
   - [ ] Voting
     - [ ] Configure
     - [ ] Start Vote
     - [ ] End Vote
   - [ ] Security
     - [ ] TLS

</details>

## ???
<details>
   <summary>Expand</summary>
   1. https://cs.brown.edu/research/pubs/theses/capstones/2019/polshakova.nina.pdf
</details>