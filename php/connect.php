<?php 
    try{
        $connection = new PDO('mysql:host=localhost;dbname=lab2', 'root', 'root');
    }catch(Exception $e){
        $connection = null;
    }
?>