<?php 
    function conn(string $db){
        if ($db == "_nodb_"){
            try{
                $con = mysqli_connect('localhost', 'root', 'root');
                return $con;
            }catch(Exception $e){
                return false;
            }
        }else{
            try{
                $con = mysqli_connect('localhost', 'root', 'root', $db);
                return $con;
            }catch(Exception $e){
                return false;
            }
        }
        
    }
?>