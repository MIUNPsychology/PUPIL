<?

include("php/SFWObject.php");

$obj = new SFWObject();
$obj->readFromForm(0);

$message = $obj->getValue("message");
$response = "PHP got '$message' from flash and responds 'hello'";

$obj->setValue("response",$response);
$obj->writeToOutput();

?>

