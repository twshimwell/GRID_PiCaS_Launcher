import unittest
import get_picas_credentials as gpc
from get_token_field import get_token_field
from set_token_field import set_token_field
import os
import couchdb
from tok_to_bash import export_tok_keys


class tok2bashtest(unittest.TestCase):

    def setUp(self):
        self.token_id='test_GRID_picastools'
        pc=gpc.picas_cred()
        creds=pc.return_credentials()  
        self.usr=creds['user']
        self.pwd=creds['password']
        self.dbn=creds['database']
        self.test_tokvarile='tests/test_tok_var.cfg'
        server = couchdb.Server("https://picas-lofar.grid.sara.nl:6984")
        server.resource.credentials = (self.usr,self.pwd)
        self.db= server[self.dbn]
        with open(self.test_tokvarile,'w') as f:
            f.write('string1: $STRING1'+'\n')
            f.write('_id: $TOKEN'+'\n')
            f.write('integer1: $INT1'+'\n')
        set_token_field(self.token_id,'string1','test_string',self.dbn,self.usr,self.pwd)
        set_token_field(self.token_id,'integer1',1234,self.dbn,self.usr,self.pwd)

    def test_read_string(self):
        os.environ['TOKEN']=self.token_id
        token=self.db[self.token_id]
        export_tok_keys(self.test_tokvarile,token)
        self.assertTrue(os.environ['STRING1']=='test_string')

    def test_read_int(self):
        os.environ['TOKEN']=self.token_id
        token=self.db[self.token_id]
        export_tok_keys(self.test_tokvarile,token)
        self.assertTrue(os.environ['INT1']=='1234')

