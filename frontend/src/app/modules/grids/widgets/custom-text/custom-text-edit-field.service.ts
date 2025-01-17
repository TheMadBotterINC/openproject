import {EditFieldHandler} from "core-app/modules/fields/edit/editing-portal/edit-field-handler";
import {ElementRef, Injector, Injectable} from "@angular/core";
import {IFieldSchema} from "core-app/modules/fields/field.base";
import {BehaviorSubject} from "rxjs";
import {GridWidgetResource} from "core-app/modules/hal/resources/grid-widget-resource";
import {CustomTextChangeset} from "core-app/modules/grids/widgets/custom-text/custom-text-changeset";

@Injectable()
export class CustomTextEditFieldService extends EditFieldHandler {
  public fieldName = 'text';
  public inEdit = false;
  public inEditMode = false;
  public inFlight = false;

  public valueChanged$:BehaviorSubject<string>;

  public changeset:CustomTextChangeset;

  constructor(protected elementRef:ElementRef,
              protected injector:Injector) {
    super();
  }

  errorMessageOnLabel:string;

  onFocusOut():void {
    // interface
  }

  public initialize(value:GridWidgetResource) {
    this.changeset = new CustomTextChangeset(this.injector, value.options);
    this.valueChanged$ = new BehaviorSubject(value.options['text'] as string);
  }

  public reinitialize(value:GridWidgetResource) {
    this.changeset = new CustomTextChangeset(this.injector, value.options);
  }

  /**
   * Handle saving the text
   */
  public handleUserSubmit():Promise<any> {
    return this.update();
  }

  public reset(withText:string = '') {
    if (withText.length > 0) {
      withText += '\n';
    }

    this.changeset.setValue('text', { raw: withText });
  }

  public get schema():IFieldSchema {
    return {
      name: I18n.t('js.grid.widgets.custom_text.title'),
      writable: true,
      required: false,
      type: 'Formattable',
      hasDefault: false
    };
  }

  private async update() {
    return this
      .onSubmit()
      .then(() => {
        this.valueChanged$.next(this.rawText);
        this.deactivate();
      });
  }

  public get rawText() {
    return _.get(this.textValue, 'raw', '');
  }

  public get htmlText() {
    return _.get(this.textValue, 'html', '');
  }

  public get textValue() {
    return this.changeset.value('text');
  }

  public handleUserCancel() {
    this.deactivate();
  }

  public get active() {
    return this.inEdit;
  }

  public activate(withText?:string) {
    this.inEdit = true;
  }

  deactivate():void {
    this.changeset.clear();
    this.inEdit = false;
  }

  focus():void {
    const trigger = this.elementRef.nativeElement.querySelector('.inplace-editing--trigger-container');
    trigger && trigger.focus();
  }

  handleUserKeydown(event:JQueryEventObject, onlyCancel?:boolean):void {
    // interface
  }

  isChanged():boolean {
    return !this.changeset.empty;
  }

  stopPropagation(evt:JQueryEventObject):boolean {
    return false;
  }
}
