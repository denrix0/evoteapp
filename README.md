# E-Voting Application
sample text

## Tools Intended to be Used in Deployment
- Flutter + Android Studio
- MongoDB + MySQL
- Node + React
- Python + Flask + Brownie + Gunicorn?
- Solidity
## Data on Server
1. Permanent
   1. Private Blockchain
      1. Vote Count
      2. Voted IDs
      3. Authorized Nodes
   2. SQL (User Data)
      1. ID
      2. PIN
      3. Salt
      4. TOTP 1 Secret
      5. TOTP 2 Secret
2. Temporary (MongoDB)
   1. Authentication Tokens
   2. RSA Pvt/AES Key
   3. User JWT

## Specifications
1. Authorization : JWT(HS512) with expiry
2. PIN : 8-64 Digits
3. Key Pair : RSA (Key Size: 2048 bits)
4. Shared Key: AES (Key Size: 256 bits)
5. Auth Tokens : Random 256-bit Hex Strings
6. Master Token : Hex value of the SHA256 Hash of the concatenated tokens seperated by '.'
   > `Token order: <uid>.<totp1>.<totp2>` 
   ```
   Example:

   Token String:
   913504352739548c95037c6719e27069232e57a592756d646d3b7722fe214a25.99efd144b4dc3609134da15098a2661b310485402ee985a4ae6860023285bfc7.d853d9d41cb8c1d6c07b786c5fc5725a452ff7d9a437f81457b01b92b17a62f7

   Master Token:
   1F3259D5FD2C139FEE9E188B810850C2B7B5E537CED083A3585855EF22837683
   ``` 


## Process

1. Creating a User
   1. Create user with id and pin
   2. Generate TOTPs
   3. Add TOTPs to devices
   4. Store ID, PIN, TOTP secrets in SQL DB
2. Voting
   1. Login using ID and PIN - Session lasts for short duration (5 minutes?)
   2. Server shares encryption key with client
   3. Go through all selected authentications using API to generate tokens
   4. Fetch and show voting form
   5. Server and client creates master token using all auth tokens
   6. Send result with master token for validation
      1. If fails, validate authenticity
         1. If reasonably valid attempt - Connect with Fail Support
         2. Else - Fail prompt
      2. If succeeds, send confirmation
   7. Delete all session data

## Authentication
1. ### Methods
   1. Secondary ID Authentication (Unique Verifiable ID, Ex. Govt ID)
   2. On-Device TOTP Authentication (Any Device)
   3. Secondary Device TOTP Authentication (Any Device)
2. ### API
   1. Login
      1. Request Example
         ```
         POST /cgi-bin/process.cgi HTTP/1.1
         {
            "id": int,
            "pin": string
         }
         ```
      2. Response Example
         ```
         {
            "jwt": string,
            "pub_key": string
         }
         ```
   2. Standard Auth
      1. Request Example
         ```
         POST /cgi-bin/process.cgi HTTP/1.1
         Authorization: Bearer <jwt>
         {
            "auth_type": string,
            "auth_content": string,
            "enc_key": string,
            "iv": string
         }
         ``` 
      2. Response Example
         ```
         {
            "token": string
         }
         ```
   3. Submit Form Auth
      1. Request Example
         ```
         POST /cgi-bin/process.cgi HTTP/1.1
         Authorization: Bearer <jwt>
         {
            "master_token": string,
            "form_option": string,
            "enc_key": string,
            "iv": string
         }
         ```
      2. Response Example
         ```
         {
            "vote_status": string,
            "message": string
         }
         ```
   4. Management Page
      1. Request
         ```
         POST /cgi-bin/process.cgi HTTP/1.1
         Authorization: Bearer <jwt>
         {
            "request": string,
            "sub_request" string,
            "data": object
         }
         ```
         > REQUEST - SUBREQUEST - DATA
         > - vote_status
         >    - start (owner only)
         >    - end (owner only)
         >    - count
         > - vote_config
         >    - fetch (owner only)
         >    - edit (owner only)
         >       ```
         >       {
         >          "vote_config": <vote_config format>,
         >          "voting_form": <voting_form format>
         >       }
         >       ```
         > - users
         >    - add
         >       ```
         >       {  
         >          "id": int,
         >          "pin": string,
         >          "totp1": string,
         >          "totp2": string
         >       }
         >       ```
         >    - fetch
         >       ```
         >       {
         >          "page": int
         >       }
         >       ```
         >    - delete
         >       ```
         >       {
         >          "id": int
         >       }
         >       ```
         > - support
         >    - fetch
         >       ```
         >       {
         >          "page": int
         >       }
         >       ```
         >    - cancel
         >       ```
         >       {
         >          "id": int
         >       }
         >      ```
      2. Example Responses
         - vote_status
           - start
               ```
               {
                  "message": "Vote started"
               }
               ```
           - end
               ```
               {
                  "message": "Vote ended"
               }
               ```
           - count
               ```
               {
                  <Option>: <Vote Count>
                  ...
               }
               ```
         - vote_config
           - fetch
               ```
               {
                  <vote_config> and <vote_form>
               }
               ``` 
           - edit
               ```
               {
                  "message": "Vote configuration changed"
               }
               ```
         - users
           - add
               ```
               {
                  "message": "User added"
               }
               ```
           - fetch
               ```
               {
                  "users": [<array of user ids>]
               }
               ``` 
           - delete
               ```
               {
                  "message": "User deleted"
               }
               ```
         - support
           - fetch
               ```
               {
                  "users": [<array of user ids>]
               }
               ```
           - cancel
               ```
               {
                  "message": "Support Request closed"
               }
               ```
   5. Fail Example
      ```
      {
         "error_type": string,
         "message": string
      }
      ```
## Data Structures
### MySQL
> Stored only on owner machine \
> Preferably only local network access

> Permissions:
> evote_node (user_details: ALL, voting_config: select)
> evote_owner (ALL)

Database - evoteapp
1. 'user_details' Table
   | ID    | Pin     | TOTP 1 | TOTP 2 |
   | ----- | ------- | ------ | ------ |
   | 23423 | 3242333 | 213123 | 213123 |
   | 23423 | 3323453 | 213123 | 213123 |

2. 'voting_config' Table (Writable owner only)
   | name        | value                  |
   | ----------- | ---------------------- |
   | prompt      | promptvalue            |
   | options     | serialized options     |
   | req_methods | serialized method list |
   | expiry      | expiry in seconds      |
   | ongoing     | boolean value          |

   > Method Names: "uid", "totp1", "totp2" \
   > Expiry Default: 600 seconds \
   > Ongoing Default: False

### MongoDB
> Stored on all systems
User data
   ```
   {
      'user_id': <User ID>
      'jwt': <JWT>
      'auth_tokens': {
         <Method Name> : <Token>,
         ...
      },
      'msg_key': <Key RSA-PVT/AES>
   }
   ```
## Todo
<details>
   <summary>Expand</summary>

1. Client
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
     - [ ] Make Auth Methods Selectable
     - [x] Authentication
       - [x] On-Device TOTP
       - [x] Secondary TOTP
       - [x] Unique ID Auth
     - [x] Voting
       - [x] Form
       - [x] Submission
     - [ ] Vote Management
   - [ ] Blokchain
     - [x] Count votes
     - [ ] Store Voted IDs
     - [ ] Authorize Nodes (Probably works, can't test)
   - [ ] Security
     - [x] RSA + AES Key Sharing
     - [x]] Encrypt data with server key
     - [ ] TLS
     - [x] Hash & Salt PIN
     - [ ] MySQL User Permissions
   - [x] Tests
3. Vote Management
   - [ ] Vote Dashboard
     - [ ] Vote Control (Owner only)
     - [ ] Bar chart
     - [ ] Configure (Owner only)
   - [ ] Users
     - [ ] Add
     - [ ] Delete
   - [ ] Vote Support
     - [ ] View Tickets
     - [ ] Remove Tickets
   - [ ] Security
     - [ ] TLS
     - [ ] JWT
   - [ ] Prettification

</details>

## ???
<details>
   <summary>Expand</summary>
   1. https://cs.brown.edu/research/pubs/theses/capstones/2019/polshakova.nina.pdf
</details>