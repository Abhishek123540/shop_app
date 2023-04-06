import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/providers/product.dart';
import 'package:shopping_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  const EditProductScreen({Key key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();

  var _editedProduct = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          // 'imageUrl': _editedProduct.imageUrl,
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      //   if ((!_imageUrlController.text.startsWith('http') &&
      //           !_imageUrlController.text.startsWith('https')) ||
      //       (!_imageUrlController.text.endsWith('.png') &&
      //           !_imageUrlController.text.endsWith('.jepg') &&
      //           !_imageUrlController.text.endsWith('.jpg'))) {
      //     return;
      //   }
      setState(() {});
    }
  }

  // void _saveForm() {
  //   final isValid = _form.currentState.validate();
  //   if (!isValid) {
  //     return;
  //   }
  //   _form.currentState.save();
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   if (_editedProduct.id != null) {
  //     Provider.of<Products>(context, listen: false)
  //         .updateProduct(_editedProduct.id, _editedProduct);
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     Navigator.of(context).pop();
  //   } else {
  //     Provider.of<Products>(context, listen: false)
  //         .addProduct(_editedProduct)
  //         .catchError((error) {
  //       return showDialog<Null>(
  //         context: context,
  //         builder: (ctx) => AlertDialog(
  //           title: Text('An error occured'),
  //           content: Text('Something went wrong'),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //               child: Text('Okay'),
  //             ),
  //           ],
  //         ),
  //       );
  //     }).then((_) {
  //       setState(() {
  //         _isLoading = true;
  //       });
  //       Navigator.of(context).pop();
  //     });
  //   }
  //   // Navigator.of(context).pop();
  // }
  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occured'),
            content: Text('Something went wrong'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Okay'),
              ),
            ],
          ),
        );
      }
      // finally {
      //   setState(() {
      //     _isLoading = true;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();

    //Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(children: [
                  TextFormField(
                    initialValue: _initValues['title'],
                    decoration: InputDecoration(labelText: 'Title'),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_priceFocusNode);
                    },
                    validator: (val) {
                      if (val.isEmpty) {
                        return 'Please provide a value';
                      }
                      return null;
                    },
                    onSaved: (val) {
                      _editedProduct = Product(
                        title: val,
                        description: _editedProduct.description,
                        imageUrl: _editedProduct.imageUrl,
                        price: _editedProduct.price,
                        id: _editedProduct.id,
                        isFavourite: _editedProduct.isFavourite,
                      );
                    },
                  ),
                  TextFormField(
                    initialValue: _initValues['price'],
                    decoration: InputDecoration(labelText: 'Price'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    focusNode: _priceFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode);
                    },
                    validator: (val) {
                      if (val.isEmpty) {
                        return 'Please enter a price';
                      }
                      if (double.tryParse(val) == null) {
                        return 'Please enter a valid number';
                      }
                      if (double.parse(val) <= 0) {
                        return 'Please enter a number greater than 0';
                      }
                      return null;
                    },
                    onSaved: (val) {
                      _editedProduct = Product(
                        title: _editedProduct.title,
                        description: _editedProduct.description,
                        imageUrl: _editedProduct.imageUrl,
                        price: double.parse(val),
                        id: _editedProduct.id,
                        isFavourite: _editedProduct.isFavourite,
                      );
                    },
                  ),
                  TextFormField(
                    initialValue: _initValues['description'],
                    decoration: InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    focusNode: _descriptionFocusNode,
                    validator: (v) {
                      if (v.isEmpty) {
                        return 'Please enter a description';
                      }
                      if (v.length < 10) {
                        return 'Should be at least 10 characters or long';
                      }
                      return null;
                    },
                    onSaved: (val) {
                      _editedProduct = Product(
                        title: _editedProduct.title,
                        description: val,
                        imageUrl: _editedProduct.imageUrl,
                        price: _editedProduct.price,
                        id: _editedProduct.id,
                        isFavourite: _editedProduct.isFavourite,
                      );
                    },
                  ),
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(top: 8, right: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        ),
                      ),
                      child: _imageUrlController.text.isEmpty
                          ? Text('Enter a URL')
                          : FittedBox(
                              child: Image.network(
                                _imageUrlController.text,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Image URL'),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        controller: _imageUrlController,
                        onEditingComplete: () {
                          setState(() {});
                        },
                        onFieldSubmitted: (_) {
                          _saveForm();
                        },
                        focusNode: _imageUrlFocusNode,
                        validator: (value) {
                          // if (value.isEmpty) {
                          //   return 'Please enter an image URL.';
                          // }
                          // if (!value.startsWith('http') &&
                          //     !value.startsWith('https')) {
                          //   return 'Please enter a valid URL';
                          // }
                          // if (!value.endsWith('.png') &&
                          //     !value.endsWith('.jpeg') &&
                          //     !value.endsWith('.jpg')) {
                          //   return 'Enter a valid Image URL';
                          // }
                          return null;
                        },
                        onSaved: (val) {
                          _editedProduct = Product(
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            imageUrl: val,
                            price: _editedProduct.price,
                            id: _editedProduct.id,
                            isFavourite: _editedProduct.isFavourite,
                          );
                        },
                      ),
                    ),
                  ])
                ]),
              ),
            ),
    );
  }
}
